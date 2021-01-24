import XCTest
@testable import SQLCodable

struct Foo : Codable {
	let key: Int
	let value: String
}

final class SQLCodableTests: XCTestCase {

	func testSQL(database: SQLDatabase) throws {
		let create = try database.makeStatement(query: "insert into test_statement values (:key, :value)")
		let read = try database.makeStatement(query: "select key, value from test_statement where key = ?1")
		let update = try database.makeStatement(query: "update test_statement set value = :value where key = :key")
		let delete = try database.makeStatement(query: "delete from test_statement where key = ?1")

		try create.setup(with: Foo(key: 1, value: "bar")).step()

		guard let foo1: Foo = try read.setup(with: 1).step() else {
			XCTFail("Unable to read Foo")
			return
		}

		try update.setup(with: Foo(key: foo1.key, value: "nop")).step()

		guard let foo2: Foo = try read.setup(with: 1).step() else {
			XCTFail("Unable to read Foo")
			return
		}

		try delete.setup(with: foo2.key).step()
	}

	func testSQLite() {
		do {
			let database = try SQLiteDatabase()

			let createTable = try database.makeStatement(query: "create table if not exists test_statement(key int primary key, value text)")
			try createTable.setup().step()

			/* Must use a function to force destroy manipulation statements, else destroy will fail, considering the table locked */
			try testSQL(database: database)

			let destroyTable = try database.makeStatement(query: "drop table if exists test_statement")
			try destroyTable.setup().step()
		} catch let error as SQLiteError {
			XCTFail(error.localizedDescription)
		} catch {
			XCTFail(error.localizedDescription)
		}
	}

	static var allTests = [
		("testSQLite", testSQLite),
	]
}
