import XCTest
@testable import SQLCodable
@testable import SQLiteCodable

// Test of the README sample

struct Student : Codable {
	struct PrimaryKey : Codable {
		let firstname: String
		let lastname: String
	}

	let firstname: String
	let lastname: String
	let average: Double
}

final class StudentDAO : SQLDataAccessObject {
	let database: SQLDatabase

	init(sqliteDatabase: SQLiteDatabase) throws {
		self.database = sqliteDatabase

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

// Basic tests for SQLite

struct Foo : Codable {
	let key: Int
	let value: String
}

final class SQLCodableTests: XCTestCase {

	func testREADMESample() {
		do {
			let studentDAO = try StudentDAO(sqliteDatabase: SQLiteDatabase())

			try studentDAO.add(student: Student(firstname: "Nino", lastname: "Quincampoix", average:  9.0))
			try studentDAO.add(student: Student(firstname: "Raphaël", lastname: "Poulain", average: 7.0))
			try studentDAO.add(student: Student(firstname: "Dominique", lastname: "Bretodeau", average: 12.0))
			try studentDAO.add(student: Student(firstname: "Raymond", lastname: "Dufayel", average: 17.0))

			try print(studentDAO.findStudent(firstname: "Dominique", lastname: "Bretodeau")!)
			try print(studentDAO.validStudents())
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
		("testREADMESample", testREADMESample),
		("testSQLite", testSQLite),
	]
}
