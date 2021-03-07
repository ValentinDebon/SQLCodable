
/**
	Data Access Object for an `SQLDatabase`.

	Create an opaque interface to your database and reduce boilerplate code with the `query` method.
*/
public protocol SQLDataAccessObject : AnyObject {
	/// Opaque database public member.
	var database: SQLDatabase { get }

	/**
		Execute a query with a set of parameters.
	
		Creates a row iterator with the associated query's statement.
		It's main reason to exist is to limit boilerplate code, but it can be replaced for example to
		dissect error messages or create statistics from queries.
	
		- Parameter query: The query for which we should acquire the associated statement.
		- Parameter parameters: The statements' reset parameters.
	*/
	@inlinable
	func query<I, O>(_ query: StaticString, with parameters: I) throws -> SQLRowIterator<O> where I : Encodable, O : Decodable
}

public extension SQLDataAccessObject {
	/**
		Default implementation, instantiating an `SQLRowIterator`.

		- Note: Implementing variadic arguments version of `query` is a big hassle.
		In the first version, I only specified one type, which quickly surfaced as a big problem.
		We only could use it with one type.So I decided to implement several `SQLVarArg*` types to handle "`Encodable` tuples", with different version.
		I don't believe users will create gigantic variadic argument queries before thinking of a new type to handle this.
		Any better solution is accepted.
	*/
	@inlinable
	func query<I, O>(_ query: StaticString, with parameters: I) throws -> SQLRowIterator<O> where I : Encodable, O : Decodable {
		try SQLRowIterator(with: self.database.statement(query), parameters: parameters)
	}

	/// Two types variadic arguments version of `query(_: StaticString, with: I)`
	func query<I1, I0, O>(_ query: StaticString, with parameters: I0, _ p1: I1) throws -> SQLRowIterator<O> where I1 : Encodable, I0 : Encodable, O : Decodable {
		try self.query(query, with: SQLVarArg1(t0: parameters, t1: p1))
	}

	/// Three types variadic arguments version of `query(_: StaticString, with: I)`
	func query<I2, I1, I0, O>(_ query: StaticString, with parameters: I0, _ p1: I1, _ p2: I2) throws -> SQLRowIterator<O> where I2 : Encodable, I1 : Encodable, I0 : Encodable, O : Decodable {
		try self.query(query, with: SQLVarArg2(t0: parameters, t1: p1, t2: p2))
	}

	/// Four types variadic arguments version of `query(_: StaticString, with: I)`
	func query<I3, I2, I1, I0, O>(_ query: StaticString, with parameters: I0, _ p1: I1, _ p2: I2, _ p3: I3) throws -> SQLRowIterator<O> where I3 : Encodable, I2 : Encodable, I1 : Encodable, I0 : Encodable, O : Decodable {
		try self.query(query, with: SQLVarArg3(t0: parameters, t1: p1, t2: p2, t3: p3))
	}

	/// Five types variadic arguments version of `query(_: StaticString, with: I)`
	func query<I4, I3, I2, I1, I0, O>(_ query: StaticString, with parameters: I0, _ p1: I1, _ p2: I2, _ p3: I3, _ p4: I4) throws -> SQLRowIterator<O> where I4 : Encodable, I3 : Encodable, I2 : Encodable, I1 : Encodable, I0 : Encodable, O : Decodable {
		try self.query(query, with: SQLVarArg4(t0: parameters, t1: p1, t2: p2, t3: p3, t4: p4))
	}

	/// Five types variadic arguments version of `query(_: StaticString, with: I)`
	func query<I5, I4, I3, I2, I1, I0, O>(_ query: StaticString, with parameters: I0, _ p1: I1, _ p2: I2, _ p3: I3, _ p4: I4, _ p5: I5) throws -> SQLRowIterator<O> where I5 : Encodable, I4 : Encodable, I3 : Encodable, I2 : Encodable, I1 : Encodable, I0 : Encodable, O : Decodable {
		try self.query(query, with: SQLVarArg5(t0: parameters, t1: p1, t2: p2, t3: p3, t4: p4, t5: p5))
	}

	/// No parameters version of `query(_: StaticString, with: I)`
	func query<O>(_ query: StaticString) throws -> SQLRowIterator<O> where O : Decodable {
		try self.query(query, with: SQLVoid())
	}
}

/// Adapter for a 2 types tuple to an `Encodable` type
fileprivate struct SQLVarArg1<T0, T1> : Encodable where T0 : Encodable, T1 : Encodable {
	let t0 : T0
	let t1 : T1

	func encode(to encoder: Encoder) throws {
		var container = encoder.unkeyedContainer()

		try container.encode(self.t0)
		try container.encode(self.t1)
	}
}

/// Adapter for a 3 types tuple to an `Encodable` type
fileprivate struct SQLVarArg2<T0, T1, T2> : Encodable where T0 : Encodable, T1 : Encodable, T2 : Encodable {
	let t0 : T0
	let t1 : T1
	let t2 : T2

	func encode(to encoder: Encoder) throws {
		var container = encoder.unkeyedContainer()

		try container.encode(self.t0)
		try container.encode(self.t1)
		try container.encode(self.t2)
	}
}

/// Adapter for a 4 types tuple to an `Encodable` type
fileprivate struct SQLVarArg3<T0, T1, T2, T3> : Encodable where T0 : Encodable, T1 : Encodable, T2 : Encodable, T3 : Encodable {
	let t0 : T0
	let t1 : T1
	let t2 : T2
	let t3 : T3

	func encode(to encoder: Encoder) throws {
		var container = encoder.unkeyedContainer()

		try container.encode(self.t0)
		try container.encode(self.t1)
		try container.encode(self.t2)
		try container.encode(self.t3)
	}
}

/// Adapter for a 5 types tuple to an `Encodable` type
fileprivate struct SQLVarArg4<T0, T1, T2, T3, T4> : Encodable where T0 : Encodable, T1 : Encodable, T2 : Encodable, T3 : Encodable, T4 : Encodable {
	let t0 : T0
	let t1 : T1
	let t2 : T2
	let t3 : T3
	let t4 : T4

	func encode(to encoder: Encoder) throws {
		var container = encoder.unkeyedContainer()

		try container.encode(self.t0)
		try container.encode(self.t1)
		try container.encode(self.t2)
		try container.encode(self.t3)
		try container.encode(self.t4)
	}
}

/// Adapter for a 6 types tuple to an `Encodable` type
fileprivate struct SQLVarArg5<T0, T1, T2, T3, T4, T5> : Encodable where T0 : Encodable, T1 : Encodable, T2 : Encodable, T3 : Encodable, T4 : Encodable, T5 : Encodable {
	let t0 : T0
	let t1 : T1
	let t2 : T2
	let t3 : T3
	let t4 : T4
	let t5 : T5

	func encode(to encoder: Encoder) throws {
		var container = encoder.unkeyedContainer()

		try container.encode(self.t0)
		try container.encode(self.t1)
		try container.encode(self.t2)
		try container.encode(self.t3)
		try container.encode(self.t4)
		try container.encode(self.t5)
	}
}
