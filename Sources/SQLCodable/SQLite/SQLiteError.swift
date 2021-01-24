import CSQLite

public struct SQLiteError : Error {
	public let errorCode: Int32

	public var localizedDescription: String {
		String(cString: sqlite3_errstr(self.errorCode))
	}
}

