
/**
	Iterator of any `SQLStatement` and Adapter to a Swift `Sequence`.
*/
public struct SQLRowIterator<O> : IteratorProtocol, Sequence where O : Decodable {
	private let statement: SQLStatement

	/**
		Create the `SQLRowIterator` and reset the statement.
	
		- Parameter statement: The statement we want to iterate through.
		- Parameter parameters: The parameters resetting the statement.
	*/
	public init<I>(with statement: SQLStatement, parameters: I) throws where I : Encodable {
		self.statement = statement
		try self.statement.reset(withParameters: parameters)
	}

	/**
		Create the `SQLRowIterator` with no specified parameters.
	
		- Parameter statement: The statement we want to iterate through.
	*/
	public init(with statement: SQLStatement) throws {
		self.statement = statement
		try self.statement.reset()
	}

	/// Acquire next statement row and don't check for exceptions
	public func next() -> O? {
		try? self.statement.nextRow()
	}
}

public extension SQLRowIterator where O == SQLVoid {
	/// Acquire next void statement and don't check for exceptions
	func next() throws {
		try self.statement.nextRow()
	}
}

