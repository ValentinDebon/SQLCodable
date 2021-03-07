import SQLCodable
import CSQLite

/**
	SQLite Database.

	`SQLDatabase` implemented using the `CSQLite` C-interface.
*/
public final class SQLiteDatabase : SQLDatabase {
	private var preparedStatements: [String : OpaquePointer]
	private let connection: OpaquePointer

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

		self.preparedStatements = [:]
		self.connection = connection!

		sqlite3_extended_result_codes(self.connection, 1)
	}

	deinit {
		self.removePreparedStatements()
		sqlite3_close(self.connection)
	}

	/**
		Access or create the `sqlite3_stmt` associated with the given query.

		- Parameter queryString: The query string for `sqlite3_stmt`.
		- Throws: `SQLiteError` if unable to create the `sqlite3_stmt`.
		- Note: Before iOS 12.0, tvOS 12.0 and watchOS 5.0 if the statement was not previously created,
		it will be created using `sqlite3_prepare_v2` and not `sqlite3_prepare_v3`, which is the default behaviour.
	*/
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

	/**
		Removes all previously prepared `sqlite3_stmt`.

		Empties the `sqlite3_stmt` internal cache. SQLite usually keeps locks on tables while prepared statements
		use them (eg. create table). This function allows you to purge the cache and thus remove these locks.

		- Note: `SQLStatement`s created from this object are safe from cache purge, as they pick them only when required.
		- SeeAlso: `statement(query:)`.
	*/
	public func removePreparedStatements() {
		for preparedStatement in self.preparedStatements.values {
			sqlite3_finalize(preparedStatement)
		}

		self.preparedStatements.removeAll()
	}

	/**
		Acquire an `SQLStatement` from this database. The `SQLiteDatabase` handles its cache directly
		with the `sqlite3_stmt`, but every of these statements hold a strong reference to the database to avoid
		any misuse.

		- Parameter query: Query source code.
		- Returns: A newly created `SQLStatement` associated with this object and `query`.
	*/
	public func statement(_ query: StaticString) -> SQLStatement {
		SQLiteStatement(database: self, queryString: String(cString: query.utf8Start))
	}
}

