/*
	SQLCodableTests.swift
	Copyright (c) 2020, Valentin Debon
	This file is part of SQLCodableTests
	subject the BSD 3-Clause License, see LICENSE
*/

@testable import SQLiteCodable
@testable import SQLCodable
import Combine
import XCTest

struct Foo : Codable, Equatable {
	let key: Int
	let value: String
}

struct EquatableError : Error, Equatable {
	let localizedDescription: String
}

final class SQLCodableTests: XCTestCase {

	private func testSQLiteEmptyRowPublisher(expectation description: String, publisher: AnyPublisher<Void, Error>, storedIn cancellables: inout Set<AnyCancellable>) -> EquatableError? {
		let expectation = self.expectation(description: description)
		var failure: EquatableError?
		publisher.sink(receiveCompletion: { completion in
				switch completion {
				case .finished:
					expectation.fulfill()
				case .failure(let error):
					failure = EquatableError(localizedDescription: error.localizedDescription)
				}
		}, receiveValue: { }).store(in: &cancellables)
		// SQLite Driver executes the statement synchronously at subscription, no timeout required
		waitForExpectations(timeout: 0)
		return failure
	}

	private func testSQLiteRowPublisher<T>(expectation description: String, publisher: AnyPublisher<T, Error>, storedIn cancellables: inout Set<AnyCancellable>) -> Result<T, EquatableError>? where T : Equatable {
		let expectation = self.expectation(description: description)
		var result: Result<T, EquatableError>?
		publisher.sink(receiveCompletion: { completion in
				switch completion {
				case .finished:
					expectation.fulfill()
				case .failure(let error):
					result = .failure(EquatableError(localizedDescription: error.localizedDescription))
				}
		}, receiveValue: { result = .success($0) }).store(in: &cancellables)
		// SQLite Driver executes the statement synchronously at subscription, no timeout required
		waitForExpectations(timeout: 0)
		return result
	}

	func testSQLite() {
		do {
			var cancellables = Set<AnyCancellable>()
			let database = try SQLiteDatabase()

			XCTAssertNil(self.testSQLiteEmptyRowPublisher(expectation: "Create Table", publisher: database.emptyRowPublisher(query: "create table if not exists test_statement(key int primary key, value text)"), storedIn: &cancellables))

			XCTAssertNil(self.testSQLiteEmptyRowPublisher(expectation: "Insert into", publisher: database.emptyRowPublisher(query: "insert into test_statement values (:key, :value)", with: Foo(key: 1, value: "bar")), storedIn: &cancellables))

			let selectPublisher: AnyPublisher<Foo, Error> = database.rowPublisher(query: "select key, value from test_statement where key = ?1", with: 1)
			XCTAssertEqual(self.testSQLiteRowPublisher(expectation: "Select 1", publisher: selectPublisher, storedIn: &cancellables), .success(Foo(key: 1, value: "bar")))

			XCTAssertNil(self.testSQLiteEmptyRowPublisher(expectation: "Update", publisher: database.emptyRowPublisher(query: "update test_statement set value = :value where key = :key", with: ["key": "1", "value" : "nop"]), storedIn: &cancellables))

			XCTAssertEqual(self.testSQLiteRowPublisher(expectation: "Select 2", publisher: selectPublisher, storedIn: &cancellables), .success(Foo(key: 1, value: "nop")))

			XCTAssertNil(self.testSQLiteEmptyRowPublisher(expectation: "Delete", publisher: database.emptyRowPublisher(query: "delete from test_statement where key = ?1", with: 1), storedIn: &cancellables))

			XCTAssertEqual(self.testSQLiteRowPublisher(expectation: "Select 3", publisher: selectPublisher, storedIn: &cancellables), nil)

			XCTAssertNil(self.testSQLiteEmptyRowPublisher(expectation: "Drop", publisher: database.emptyRowPublisher(query: "drop table test_statement"), storedIn: &cancellables))
		} catch {
			XCTFail(error.localizedDescription)
		}
	}

	static var allTests = [
		("testSQLite", testSQLite),
	]
}
