/*
	SQLiteStatement.swift
	Copyright (c) 2020, Valentin Debon
	This file is part of SQLiteCodable
	subject the BSD 3-Clause License, see LICENSE
*/

import Combine
import SQLCodable
import CSQLite

final class SQLiteRowPublisher<Output> : Publisher where Output : Decodable {
	typealias Failure = Error
	
	private let database: SQLiteDatabase
	private let preparedStatement: OpaquePointer
	private let parameters: Encodable

	init<I>(query: StaticString, with parameters: I, on database: SQLiteDatabase) throws where I : Encodable {
		let queryString = String(cString: query.utf8Start)
		var pStmt: OpaquePointer?

		let errorCode: Int32 = queryString.withCString { queryCString in
			sqlite3_prepare_v2(database.connection, queryCString, Int32(queryString.utf8.count + 1), &pStmt, nil)
		}

		guard errorCode == SQLITE_OK else {
			if let error = SQLiteError(rawValue: errorCode) {
				throw error
			}
			fatalError("Unsupported error code \(errorCode) raised while preparing query: \(query)")
		}

		guard let preparedStatement = pStmt else {
			fatalError("Invalid null valid prepared statement for query: \(query)")
		}

		self.database = database
		self.preparedStatement = preparedStatement
		self.parameters = parameters
	}

	deinit {
		sqlite3_finalize(self.preparedStatement)
	}

	func receive<S>(subscriber: S) where S : Subscriber, Error == S.Failure, Output == S.Input {
		do {
			subscriber.receive(subscription: Subscriptions.empty)

			sqlite3_reset(preparedStatement)
			sqlite3_clear_bindings(preparedStatement)
			try self.parameters.encode(to: SQLiteEncoder(prepared: preparedStatement))

			var errorCode : Int32
			var finished = false

			repeat {
				errorCode = sqlite3_step(self.preparedStatement)

				switch errorCode {
				case SQLITE_DONE:
					finished = true
				case SQLITE_ROW:
					switch try subscriber.receive(Output(from: SQLiteDecoder(prepared: preparedStatement))) {
					case .none:
						finished = true
					default:
						break
					}
				default:
					if let error = SQLiteError(rawValue: errorCode) {
						throw error
					}
					fatalError("Unsupported error code \(errorCode) raised while performing statement")
				}
			} while !finished

			subscriber.receive(completion: .finished)
		} catch {
			subscriber.receive(completion: .failure(error))
		}
	}
}
