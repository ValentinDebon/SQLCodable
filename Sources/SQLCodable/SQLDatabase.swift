/*
	SQLDatabase.swift
	Copyright (c) 2020, Valentin Debon
	This file is part of SQLCodable
	subject the BSD 3-Clause License, see LICENSE
*/

/// Used to implement a Database backend.
public protocol SQLDatabase : AnyObject {
	/**
		Access the shared statement for the associated query.

		- Parameter query: The query, in the database's `SQL` dialect, associated with the returned statement.
		- Returns: The statement associated with `query`, shared accross the database instance.
		- SeeAlso: `SQLStatement`.
	*/
	func statement(_ query: StaticString) -> SQLStatement
}

