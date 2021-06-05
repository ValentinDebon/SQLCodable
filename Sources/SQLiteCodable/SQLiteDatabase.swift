/*
	SQLiteDatabase.swift
	Copyright (c) 2020, Valentin Debon
	This file is part of SQLiteCodable
	subject the BSD 3-Clause License, see LICENSE
*/

import Combine
import SQLCodable
import CSQLite

/**
	SQLite Database.

	`SQLDatabase` implemented using the `CSQLite` C-interface.
*/
public final class SQLiteDatabase : SQLDatabase {
	let connection: OpaquePointer

	/**
		Create an sqlite database from a file or in-memory.

		- Parameter filename: File in which the database is created, or `:memory:` for an in-memory database. Default is `:memory:`.
		- Throws: `SQLiteError` if unable to open `filename`.
	*/
	public init(filename: String = ":memory:") throws {
		var connection: OpaquePointer?

		guard sqlite3_open(filename, &connection) == SQLITE_OK else {
			defer { sqlite3_close(connection) }
			throw SQLiteError(rawValue: sqlite3_extended_errcode(connection))!
		}

		self.connection = connection!

		sqlite3_extended_result_codes(self.connection, 1)
	}

	deinit {
		sqlite3_close(self.connection)
	}

	public func rowPublisher<Input, Output>(query: StaticString, with parameters: Input) -> AnyPublisher<Output, Error> where Input : Encodable, Output : Decodable {
		do {
			return try SQLiteRowPublisher(query: query, with: parameters, on: self).eraseToAnyPublisher()
		} catch {
			return Fail(outputType: Output.self, failure: error).eraseToAnyPublisher()
		}
	}
}
