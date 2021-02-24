import SQLCodable
import CSQLite

public final class SQLiteDatabase : SQLDatabase {
	private var preparedStatements: [String : OpaquePointer]
	private let connection: OpaquePointer

	public init(filename: String = ":memory:") throws {
		var connection: OpaquePointer?

		guard sqlite3_open(filename, &connection) == SQLITE_OK else {
			defer { sqlite3_close(connection) }
			throw SQLiteError(rawValue: sqlite3_extended_errcode(connection))!
		}

		self.preparedStatements = [:]
		self.connection = connection!

		sqlite3_extended_result_codes(self.connection, 1)
	}

	deinit {
		self.removePreparedStatements()
		sqlite3_close(self.connection)
	}

	func preparedStatement(forQuery queryString: String) throws -> OpaquePointer {
		if let preparedStatement = self.preparedStatements[queryString] {
			return preparedStatement
		} else {
			var pStmt: OpaquePointer?

			let errorCode: Int32 = queryString.withCString { queryCString in
				if #available(iOS 12.0, tvOS 12.0, watchOS 5.0, *) {
					return sqlite3_prepare_v3(self.connection, queryCString,
									   Int32(queryString.utf8.count + 1), UInt32(SQLITE_PREPARE_PERSISTENT),
									   &pStmt, nil)
				} else {
					return sqlite3_prepare_v2(self.connection, queryCString,
									   Int32(queryString.utf8.count + 1), &pStmt, nil)
				}
			}

			guard errorCode == SQLITE_OK else {
				throw SQLiteError(rawValue: errorCode)!
			}

			guard let preparedStatement = pStmt else {
				fatalError("Invalid null valid prepared statement for query: \(queryString)")
			}

			if let replaced = self.preparedStatements.updateValue(preparedStatement, forKey: queryString) {
				fatalError("\(Self.self): invalid previous query in prepared statements: \(replaced) for query: \(queryString)")
			}

			return preparedStatement
		}
	}

	public func removePreparedStatements() {
		for preparedStatement in self.preparedStatements.values {
			sqlite3_finalize(preparedStatement)
		}

		self.preparedStatements.removeAll()
	}

	public func statement(_ query: StaticString) -> SQLStatement {
		SQLiteStatement(database: self, queryString: String(cString: query.utf8Start))
	}
}

