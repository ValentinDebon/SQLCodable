import XCTest
@testable import SQLCodable

struct Foo : Codable {
	let key: Int
	let value: String
}

final class SQLCodableTests: XCTestCase {
	func testSQLite() {
		do {
			let database: SQLDatabase = try SQLiteDatabase()

			let createTable = try database.makeStatement(query: "create table if not exists test_statement(key int primary key, value text)")
			try createTable.setup().step()

			let create = try database.makeStatement(query: "insert into test_statement values (:key, :value)")
			let read = try database.makeStatement(query: "select key, value from test_statement where key = ?1")
			let update = try database.makeStatement(query: "update test_statement set value = :value where key = :key")
			let delete = try database.makeStatement(query: "delete from test_statement where key = ?1")
			try create.setup(with: Foo(key: 1, value: "bar")).step()
			try delete.setup(with: 1).step()

			let destroyTable = try database.makeStatement(query: "drop table if exists test_statement")
			try destroyTable.setup().step()
		} catch {
			XCTFail(error.localizedDescription)
		}
	}

	static var allTests = [
		("testSQLite", testSQLite),
	]
}
