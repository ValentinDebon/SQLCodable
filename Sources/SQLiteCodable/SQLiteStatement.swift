import SQLCodable
import CSQLite

struct SQLiteStatement : SQLStatement {
	private let database: SQLiteDatabase
	private let queryString: String

	init(database: SQLiteDatabase, queryString: String) {
		self.database = database
		self.queryString = queryString
	}

	func reset<I>(withParameters parameters: I) throws where I : Encodable {
		let preparedStatement = try self.database.preparedStatement(forQuery: queryString)

		sqlite3_reset(preparedStatement)
		sqlite3_clear_bindings(preparedStatement)

		try parameters.encode(to: SQLiteEncoder(prepared: preparedStatement))
	}

	func nextRow<O>() throws -> O? where O : Decodable {
		let preparedStatement = try self.database.preparedStatement(forQuery: queryString)
		let errorCode = sqlite3_step(preparedStatement)

		switch errorCode {
		case SQLITE_ROW:
			return try O(from: SQLiteDecoder(prepared: preparedStatement))
		case SQLITE_DONE:
			return nil
		default:
			throw SQLiteError(rawValue: errorCode)!
		}
	}
}

