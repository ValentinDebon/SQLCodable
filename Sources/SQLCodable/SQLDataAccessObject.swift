
public protocol SQLDataAccessObject : AnyObject {
	var database: SQLDatabase { get }

	func query<I, O>(_ query: StaticString, with parameters: I) throws -> SQLRowIterator<O> where I : Encodable, O : Decodable
}

public extension SQLDataAccessObject {
	func query<I, O>(_ query: StaticString, with parameters: I) throws -> SQLRowIterator<O> where I : Encodable, O : Decodable {
		try SQLRowIterator(with: self.database.statement(query), parameters: parameters)
	}

	func query<I, O>(_ query: StaticString, with parameters: I...) throws -> SQLRowIterator<O> where I : Encodable, O : Decodable {
		try SQLRowIterator(with: self.database.statement(query), parameters: Array(parameters))
	}

	func query<O>(_ query: StaticString) throws -> SQLRowIterator<O> where O : Decodable {
		try SQLRowIterator(with: self.database.statement(query))
	}
}

