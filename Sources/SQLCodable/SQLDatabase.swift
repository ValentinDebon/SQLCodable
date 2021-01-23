
public protocol SQLDatabase : AnyObject {
	func makeStatement(query: StaticString) throws -> SQLStatement
}

