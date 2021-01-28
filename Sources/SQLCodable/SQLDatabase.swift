
public protocol SQLDatabase : AnyObject {
	func statement(_ query: StaticString) -> SQLStatement
}

