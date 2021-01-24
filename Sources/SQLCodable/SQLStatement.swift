
struct SQLVoid : Codable {
}

public struct SQLRowSequence<T>: IteratorProtocol, Sequence where T : Decodable {
	public typealias Element = T

	fileprivate let statement: SQLStatement

	public func next() -> Self.Element? {
		try? self.statement.step()
	}
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

	func over<T>(_ type: T.Type = T.self) -> SQLRowSequence<T> {
		SQLRowSequence(statement: self)
	}
}

