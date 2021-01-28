
public struct SQLRowIterator<O> : IteratorProtocol, Sequence where O : Decodable {
	private let statement: SQLStatement

	public init<I>(with statement: SQLStatement, parameters: I) throws where I : Encodable {
		self.statement = statement
		try self.statement.reset(withParameters: parameters)
	}

	public init(with statement: SQLStatement) throws {
		self.statement = statement
		try self.statement.reset()
	}

	public func next() -> O? {
		try? self.statement.nextRow()
	}
}

public extension SQLRowIterator where O == SQLVoid {
	func next() throws {
		try self.statement.nextRow()
	}
}

