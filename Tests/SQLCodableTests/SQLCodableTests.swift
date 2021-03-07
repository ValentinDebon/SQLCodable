/*
	SQLCodableTests.swift
	Copyright (c) 2020, Valentin Debon
	This file is part of SQLCodableTests
	subject the BSD 3-Clause License, see LICENSE
*/

@testable import SQLiteCodable
@testable import SQLCodable
import XCTest

final class SQLCodableTests: XCTestCase {

	func testREADME() {
		do {
			let studentDAO = try StudentDAO(database: SQLiteDatabase())

			try studentDAO.add(student: Student(firstname: "Nino", lastname: "Quincampoix", average:  9.0))
			try studentDAO.add(student: Student(firstname: "Raphaël", lastname: "Poulain", average: 7.0))
			try studentDAO.add(student: Student(firstname: "Dominique", lastname: "Bretodeau", average: 12.0))
			try studentDAO.add(student: Student(firstname: "Raymond", lastname: "Dufayel", average: 17.0))

			try XCTAssertEqual(studentDAO.findStudent(firstname: "Dominique", lastname: "Bretodeau"),
							   Student(firstname: "Dominique", lastname: "Bretodeau", average: 12.0))
			try XCTAssertEqual(studentDAO.validStudents(),
							   [Student(firstname: "Raymond", lastname: "Dufayel", average: 17.0),
								Student(firstname: "Dominique", lastname: "Bretodeau", average: 12.0)])
		} catch {
			XCTFail(error.localizedDescription)
		}
	}

	func testSQLite() {
		do {
			let database = try SQLiteDatabase()

			// Creating table
			let create = database.statement("create table if not exists test_statement(key int primary key, value text)")
			try create.reset()
			try create.nextRow()

			// Few manipulations
			let insert = database.statement("insert into test_statement values (:key, :value)")
			let read = database.statement("select key, value from test_statement where key = ?1")
			let update = database.statement("update test_statement set value = :value where key = :key")
			let delete = database.statement("delete from test_statement where key = ?1")
	
			try insert.reset(withParameters: Foo(key: 1, value: "bar"))
			try insert.nextRow()
	
			try read.reset(withParameters: 1)
			guard let foo1: Foo = try read.nextRow() else {
				XCTFail("Unable to read Foo 1")
				return
			}
	
			try update.reset(withParameters: ["key" : String(foo1.key), "value" : "nop"])
			try update.nextRow()
	
			try read.reset(withParameters: 1)
			guard let foo2: Foo = try read.nextRow() else {
				XCTFail("Unable to read Foo 2")
				return
			}
	
			try delete.reset(withParameters: foo2.key)
			try delete.nextRow()

			database.removePreparedStatements() // SQLite is a bit paranoid and locks a table as long as there are prepared statements using it.

			// Destroying table
			let destroy = database.statement("drop table if exists test_statement")
			try destroy.reset()
			try destroy.nextRow()

		} catch {
			XCTFail(error.localizedDescription)
		}
	}

	static var allTests = [
		("testREADME", testREADME),
		("testSQLite", testSQLite),
	]
}
