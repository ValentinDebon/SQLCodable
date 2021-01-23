import CSQLite

public final class SQLiteDatabase : SQLDatabase {
	let connection: OpaquePointer

	public init(filename: String = ":memory:") throws {
		var connection: OpaquePointer?

		guard sqlite3_open(filename, &connection) == SQLITE_OK else {
			defer { sqlite3_close(connection) }
			throw SQLiteError(errorCode: sqlite3_extended_errcode(connection))
		}

		self.connection = connection!
	}

	deinit {
		sqlite3_close(self.connection)
	}

	public func makeStatement(query: StaticString) throws -> SQLStatement {
		try SQLiteStatement(database: self, query: query)
	}
}

