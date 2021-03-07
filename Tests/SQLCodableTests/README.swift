/*
	README.swift
	Copyright (c) 2020, Valentin Debon
	This file is part of SQLCodableTests
	subject the BSD 3-Clause License, see LICENSE
*/

@testable import SQLCodable

struct Student : Codable {
	let firstname: String
	let lastname: String
	let average: Double
}

final class StudentDAO : SQLDataAccessObject {
	let database: SQLDatabase

	init(database: SQLDatabase) throws {
		self.database = database

		try self.query("""
			create table if not exists students (
				firstname text,
				lastname text,
				average real,

				primary key (firstname, lastname)
			)
		""").next()
	}

	func add(student: Student) throws {
		try self.query("insert into students values (:firstname, :lastname, :average)", with: student).next()
	}

	func findStudent(firstname: String, lastname: String) throws -> Student? {
		try self.query("select * from students where firstname = ?1 and lastname = ?2", with: firstname, lastname).next()
	}

	func validStudents(minimum average: Double = 10.0) throws -> [Student] {
		try Array(self.query("select * from students where average >= ?1 order by average desc", with: average))
	}
}

// Required for XCTAssertEqual
extension Student : Equatable {
	static func ==(lhs: Self, rhs: Self) -> Bool {
		lhs.firstname == rhs.firstname &&
			lhs.lastname == rhs.lastname &&
			lhs.average == rhs.average
	}
}
