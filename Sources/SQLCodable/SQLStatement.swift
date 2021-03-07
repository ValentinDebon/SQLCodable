/*
	SQLStatement.swift
	Copyright (c) 2020, Valentin Debon
	This file is part of SQLCodable
	subject the BSD 3-Clause License, see LICENSE
*/

/**
	A database statement.

	Every `SQLStatement` is shared throughout the database which created it.
	Which means you can't request concurrently the same query inside the same database.
	You should open multiple connections if you want a request done in parallel.
	All valid implementations should uphold this constraint.
*/
public protocol SQLStatement {
	/**
		Reset the statement with a new set of parameters.

		- Parameter parameters: New parameters associated with this statement.
		- Throws: Internal exception, see backend.
	*/
	func reset<I>(withParameters parameters: I) throws where I : Encodable

	/**
		Acquire next row of statement.

		- Returns: The next row of the statement, `nil` if end.
		- Throws: Internal exception, see backend.
	*/
	func nextRow<O>() throws -> O? where O : Decodable
}

public extension SQLStatement {
	/**
		Reset the statement with an empty set of parameters.

		- Throws: Internal exception, see backend.
	*/
	func reset() throws {
		try self.reset(withParameters: SQLVoid())
	}

	/**
		Acquire next row, but don't acquire value.

		- Returns: `true` if a row was acquired, `false` if end.
		- Throws: Internal excpetion, see backend.
	*/
	@discardableResult
	func nextRow() throws -> Bool {
		if let _: SQLVoid = try self.nextRow() {
			return true
		} else {
			return false
		}
	}
}

