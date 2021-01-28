
public protocol SQLStatement {
	func reset<I>(withParameters parameters: I) throws where I : Encodable
	func nextRow<O>() throws -> O? where O : Decodable
}

public extension SQLStatement {
	func reset() throws {
		try self.reset(withParameters: SQLVoid())
	}

	@discardableResult
	func nextRow() throws -> Bool {
		if let _: SQLVoid = try self.nextRow() {
			return true
		} else {
			return false
		}
	}
}

