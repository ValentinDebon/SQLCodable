/*
	SQLDatabase.swift
	Copyright (c) 2020, Valentin Debon
	This file is part of SQLCodable
	subject the BSD 3-Clause License, see LICENSE
*/
import Combine

/// Used to implement a Database backend.
public protocol SQLDatabase : AnyObject {
	func rowPublisher<I, O>(query: StaticString, with parameters: I) -> AnyPublisher<O, Error> where I : Encodable, O : Decodable
}

public extension SQLDatabase {
	func emptyRowPublisher<I>(query: StaticString, with parameters: I) -> AnyPublisher<Void, Error> where I : Encodable {
		self.rowPublisher(query: query, with: parameters).map({ (_: SQLVoid) in () }).eraseToAnyPublisher()
	}

	func emptyRowPublisher(query: StaticString) -> AnyPublisher<Void, Error> {
		self.emptyRowPublisher(query: query, with: SQLVoid())
	}

	func emptyRowPublisher<I1, I0>(query: StaticString, with parameters: I0, _ p1: I1) -> AnyPublisher<Void, Error> where I1 : Encodable, I0 : Encodable {
		self.emptyRowPublisher(query: query, with: SQLVarArg1(t0: parameters, t1: p1))
	}

	func emptyRowPublisher<I2, I1, I0>(query: StaticString, with parameters: I0, _ p1: I1, _ p2: I2) -> AnyPublisher<Void, Error> where I2 : Encodable, I1 : Encodable, I0 : Encodable {
		self.emptyRowPublisher(query: query, with: SQLVarArg2(t0: parameters, t1: p1, t2: p2))
	}
	
	func emptyRowPublisher<I3, I2, I1, I0>(query: StaticString, with parameters: I0, _ p1: I1, _ p2: I2, _ p3: I3) -> AnyPublisher<Void, Error> where I3 : Encodable, I2 : Encodable, I1 : Encodable, I0 : Encodable {
		self.emptyRowPublisher(query: query, with: SQLVarArg3(t0: parameters, t1: p1, t2: p2, t3: p3))
	}
	
	func emptyRowPublisher<I4, I3, I2, I1, I0>(query: StaticString, with parameters: I0, _ p1: I1, _ p2: I2, _ p3: I3, _ p4: I4) -> AnyPublisher<Void, Error> where I4 : Encodable, I3 : Encodable, I2 : Encodable, I1 : Encodable, I0 : Encodable {
		self.emptyRowPublisher(query: query, with: SQLVarArg4(t0: parameters, t1: p1, t2: p2, t3: p3, t4: p4))
	}
	
	func emptyRowPublisher<I5, I4, I3, I2, I1, I0>(query: StaticString, with parameters: I0, _ p1: I1, _ p2: I2, _ p3: I3, _ p4: I4, _ p5: I5) -> AnyPublisher<Void, Error> where I5 : Encodable, I4 : Encodable, I3 : Encodable, I2 : Encodable, I1 : Encodable, I0 : Encodable {
		self.emptyRowPublisher(query: query, with: SQLVarArg5(t0: parameters, t1: p1, t2: p2, t3: p3, t4: p4, t5: p5))
	}

	func rowPublisher<O>(query: StaticString) -> AnyPublisher<O, Error> where O : Decodable {
		self.rowPublisher(query: query, with: SQLVoid())
	}

	func rowPublisher<I1, I0, O>(query: StaticString, with parameters: I0, _ p1: I1) -> AnyPublisher<O, Error> where I1 : Encodable, I0 : Encodable, O : Decodable {
		self.rowPublisher(query: query, with: SQLVarArg1(t0: parameters, t1: p1))
	}

	func rowPublisher<I2, I1, I0, O>(query: StaticString, with parameters: I0, _ p1: I1, _ p2: I2) -> AnyPublisher<O, Error> where I2 : Encodable, I1 : Encodable, I0 : Encodable, O : Decodable {
		self.rowPublisher(query: query, with: SQLVarArg2(t0: parameters, t1: p1, t2: p2))
	}
	
	func rowPublisher<I3, I2, I1, I0, O>(query: StaticString, with parameters: I0, _ p1: I1, _ p2: I2, _ p3: I3) -> AnyPublisher<O, Error> where I3 : Encodable, I2 : Encodable, I1 : Encodable, I0 : Encodable, O : Decodable {
		self.rowPublisher(query: query, with: SQLVarArg3(t0: parameters, t1: p1, t2: p2, t3: p3))
	}
	
	func rowPublisher<I4, I3, I2, I1, I0, O>(query: StaticString, with parameters: I0, _ p1: I1, _ p2: I2, _ p3: I3, _ p4: I4) -> AnyPublisher<O, Error> where I4 : Encodable, I3 : Encodable, I2 : Encodable, I1 : Encodable, I0 : Encodable, O : Decodable {
		self.rowPublisher(query: query, with: SQLVarArg4(t0: parameters, t1: p1, t2: p2, t3: p3, t4: p4))
	}
	
	func rowPublisher<I5, I4, I3, I2, I1, I0, O>(query: StaticString, with parameters: I0, _ p1: I1, _ p2: I2, _ p3: I3, _ p4: I4, _ p5: I5) -> AnyPublisher<O, Error> where I5 : Encodable, I4 : Encodable, I3 : Encodable, I2 : Encodable, I1 : Encodable, I0 : Encodable, O : Decodable {
		self.rowPublisher(query: query, with: SQLVarArg5(t0: parameters, t1: p1, t2: p2, t3: p3, t4: p4, t5: p5))
	}
}

/// Empty struct to encode/decode `Void`.
fileprivate struct SQLVoid : Codable {
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
