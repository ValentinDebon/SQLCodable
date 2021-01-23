
struct SQLVoid : Codable {
}

public protocol SQLStatement : AnyObject {
	func setup<I>(with input: I) throws -> Self where I : Encodable
	func step<O>() throws -> O? where O : Decodable
}

public extension SQLStatement {
	func setup() throws -> Self {
		try self.setup(with: SQLVoid())
	}

	func step() throws {
		let _: SQLVoid? = try self.step()
	}
}

