import CSQLite

final class SQLiteStatement : SQLStatement {
	private let database: SQLiteDatabase
	private let prepared: OpaquePointer

	init(database: SQLiteDatabase, query: StaticString) throws {
		var prepared: OpaquePointer?

		let errorCode = query.utf8Start.withMemoryRebound(to: Int8.self, capacity: query.utf8CodeUnitCount + 1) { cquery in
			sqlite3_prepare_v3(database.connection, cquery,
				Int32(query.utf8CodeUnitCount + 1), UInt32(SQLITE_PREPARE_PERSISTENT),
				&prepared, nil)
		}

		guard errorCode == SQLITE_OK else {
			throw SQLiteError(errorCode: errorCode)
		}

		self.database = database
		self.prepared = prepared!
	}

	deinit {
		sqlite3_finalize(self.prepared)
	}

	func setup<I>(with input: I) throws -> Self where I : Encodable {

		sqlite3_clear_bindings(self.prepared)

		try input.encode(to: SQLiteEncoder(prepared: self.prepared))

		return self
	}

	func step<O>() throws -> O? where O : Decodable {
		let errorCode = sqlite3_step(self.prepared)

		switch errorCode {
		case SQLITE_ROW:
			return try O(from: SQLiteDecoder(prepared: self.prepared))
		case SQLITE_DONE:
			sqlite3_reset(self.prepared)
			return nil
		default:
			throw SQLiteError(errorCode: errorCode)
		}
	}
}

