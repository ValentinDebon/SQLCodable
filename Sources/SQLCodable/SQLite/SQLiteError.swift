import CSQLite

struct SQLiteError : Error {
	let errorCode: Int32

	var localizedDescription: String {
		String(cString: sqlite3_errstr(self.errorCode))
	}
}

