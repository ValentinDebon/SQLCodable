import CSQLite

fileprivate extension CodingKey {
	var sqliteParameterValue : String {
		":" + self.stringValue
	}
}

fileprivate struct SQLiteKeyedEncodingContainer<Key> : KeyedEncodingContainerProtocol where Key : CodingKey {
	let codingPath: [CodingKey] = []
	let prepared: OpaquePointer

	private func check(forKey key: Key, binding: @escaping (OpaquePointer, Int32) -> Int32) throws {
		let parameterIndex = key.sqliteParameterValue.withCString { sqlite3_bind_parameter_index(self.prepared, $0) }

		guard parameterIndex > 0 else {
			let encodingContext = EncodingError.Context(codingPath: self.codingPath, debugDescription: "Invalid key \(key) for query")
			throw EncodingError.invalidValue(key, encodingContext)
		}

		let errorCode = binding(self.prepared, parameterIndex)

		if errorCode != SQLITE_OK {
			throw SQLiteError(errorCode: errorCode)
		}
	}

	mutating func encodeNil(forKey key: Key) throws {
		try self.check(forKey: key) { sqlite3_bind_null($0, $1) }
	}

	mutating func encode(_ value: Bool, forKey key: Key) throws {
		try self.check(forKey: key) { sqlite3_bind_int64($0, $1, sqlite3_int64(value ? 1 : 0)) }
	}

	mutating func encode(_ value: String, forKey key: Key) throws {
		try value.withCString { cString in
			try self.check(forKey: key) { sqlite3_bind_text($0, $1, cString, Int32(value.utf8.count), sqlite_transient) }
		}
	}

	mutating func encode(_ value: Double, forKey key: Key) throws {
		try self.check(forKey: key) { sqlite3_bind_double($0, $1, value) }
	}

	mutating func encode(_ value: Float, forKey key: Key) throws {
		try self.check(forKey: key) { sqlite3_bind_double($0, $1, Double(value)) }
	}

	mutating func encode(_ value: Int, forKey key: Key) throws {
		try self.check(forKey: key) { sqlite3_bind_int64($0, $1, sqlite3_int64(value)) }
	}

	mutating func encode(_ value: Int8, forKey key: Key) throws {
		try self.check(forKey: key) { sqlite3_bind_int64($0, $1, sqlite3_int64(value)) }
	}

	mutating func encode(_ value: Int16, forKey key: Key) throws {
		try self.check(forKey: key) { sqlite3_bind_int64($0, $1, sqlite3_int64(value)) }
	}

	mutating func encode(_ value: Int32, forKey key: Key) throws {
		try self.check(forKey: key) { sqlite3_bind_int64($0, $1, sqlite3_int64(value)) }
	}

	mutating func encode(_ value: Int64, forKey key: Key) throws {
		try self.check(forKey: key) { sqlite3_bind_int64($0, $1, sqlite3_int64(value)) }
	}

	mutating func encode(_ value: UInt, forKey key: Key) throws {
		try self.check(forKey: key) { sqlite3_bind_int64($0, $1, sqlite3_int64(value)) }
	}

	mutating func encode(_ value: UInt8, forKey key: Key) throws {
		try self.check(forKey: key) { sqlite3_bind_int64($0, $1, sqlite3_int64(value)) }
	}

	mutating func encode(_ value: UInt16, forKey key: Key) throws {
		try self.check(forKey: key) { sqlite3_bind_int64($0, $1, sqlite3_int64(value)) }
	}

	mutating func encode(_ value: UInt32, forKey key: Key) throws {
		try self.check(forKey: key) { sqlite3_bind_int64($0, $1, sqlite3_int64(value)) }
	}

	mutating func encode(_ value: UInt64, forKey key: Key) throws {
		try self.check(forKey: key) { sqlite3_bind_int64($0, $1, sqlite3_int64(value)) }
	}

	mutating func encode<T>(_ value: T, forKey key: Key) throws where T : Encodable {
		let encodingContext = EncodingError.Context(codingPath: self.codingPath, debugDescription: "Unsupported encoding for key \(key)")
		throw EncodingError.invalidValue(key, encodingContext)
	}

	mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
		fatalError()
	}

	mutating func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
		fatalError()
	}

	mutating func superEncoder() -> Encoder {
		fatalError()
	}

	mutating func superEncoder(forKey key: Key) -> Encoder {
		fatalError()
	}
}

fileprivate struct SQLiteUnkeyedEncodingContainer : UnkeyedEncodingContainer, SingleValueEncodingContainer {
	private(set) var count: Int = 0

	let codingPath: [CodingKey] = []
	let prepared: OpaquePointer

	private mutating func check(binding: @escaping (OpaquePointer, Int32) -> Int32) throws {
		let parameterIndex = Int32(self.count + 1)
		let errorCode = binding(self.prepared, parameterIndex)

		if errorCode != SQLITE_OK {
			throw SQLiteError(errorCode: errorCode)
		}

		self.count += 1
	}

	mutating func encodeNil() throws {
		try self.check { sqlite3_bind_null($0, $1) }
	}

	mutating func encode(_ value: Bool) throws {
		try self.check { sqlite3_bind_int64($0, $1, sqlite3_int64(value ? 1 : 0)) }
	}

	mutating func encode(_ value: String) throws {
		try value.withCString { cString in
			try self.check { sqlite3_bind_text($0, $1, cString, Int32(value.utf8.count), sqlite_transient) }
		}
	}

	mutating func encode(_ value: Double) throws {
		try self.check { sqlite3_bind_double($0, $1, value) }
	}

	mutating func encode(_ value: Float) throws {
		try self.check { sqlite3_bind_double($0, $1, Double(value)) }
	}

	mutating func encode(_ value: Int) throws {
		try self.check { sqlite3_bind_int64($0, $1, sqlite3_int64(value)) }
	}

	mutating func encode(_ value: Int8) throws {
		try self.check { sqlite3_bind_int64($0, $1, sqlite3_int64(value)) }
	}

	mutating func encode(_ value: Int16) throws {
		try self.check { sqlite3_bind_int64($0, $1, sqlite3_int64(value)) }
	}

	mutating func encode(_ value: Int32) throws {
		try self.check { sqlite3_bind_int64($0, $1, sqlite3_int64(value)) }
	}

	mutating func encode(_ value: Int64) throws {
		try self.check { sqlite3_bind_int64($0, $1, sqlite3_int64(value)) }
	}

	mutating func encode(_ value: UInt) throws {
		try self.check { sqlite3_bind_int64($0, $1, sqlite3_int64(value)) }
	}

	mutating func encode(_ value: UInt8) throws {
		try self.check { sqlite3_bind_int64($0, $1, sqlite3_int64(value)) }
	}

	mutating func encode(_ value: UInt16) throws {
		try self.check { sqlite3_bind_int64($0, $1, sqlite3_int64(value)) }
	}

	mutating func encode(_ value: UInt32) throws {
		try self.check { sqlite3_bind_int64($0, $1, sqlite3_int64(value)) }
	}

	mutating func encode(_ value: UInt64) throws {
		try self.check { sqlite3_bind_int64($0, $1, sqlite3_int64(value)) }
	}

	mutating func encode<T>(_ value: T) throws where T : Encodable {
		let encodingContext = EncodingError.Context(codingPath: self.codingPath, debugDescription: "Unsupported encoding")
		throw EncodingError.invalidValue(value, encodingContext)
	}

	mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
		fatalError()
	}

	mutating func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
		fatalError()
	}

	mutating func superEncoder() -> Encoder {
		fatalError()
	}
}

fileprivate struct SQLiteSingleValueEncodingContainer : SingleValueEncodingContainer {
	let codingPath: [CodingKey] = []
	let prepared: OpaquePointer

	private func check(binding errorCode: Int32) throws {
		if errorCode != SQLITE_OK {
			throw SQLiteError(errorCode: errorCode)
		}
	}

	mutating func encodeNil() throws {
		try self.check(binding: sqlite3_bind_null(self.prepared, 1))
	}

	mutating func encode(_ value: Bool) throws {
		try self.check(binding: sqlite3_bind_int64(self.prepared, 1, sqlite3_int64(value ? 1 : 0)))
	}

	mutating func encode(_ value: String) throws {
		try value.withCString { cString in
			try self.check(binding: sqlite3_bind_text(self.prepared, 1, cString, Int32(value.utf8.count), sqlite_transient))
		}
	}

	mutating func encode(_ value: Double) throws {
		try self.check(binding: sqlite3_bind_double(self.prepared, 1, value))
	}

	mutating func encode(_ value: Float) throws {
		try self.check(binding: sqlite3_bind_double(self.prepared, 1, Double(value)))
	}

	mutating func encode(_ value: Int) throws {
		try self.check(binding: sqlite3_bind_int64(self.prepared, 1, sqlite3_int64(value)))
	}

	mutating func encode(_ value: Int8) throws {
		try self.check(binding: sqlite3_bind_int64(self.prepared, 1, sqlite3_int64(value)))
	}

	mutating func encode(_ value: Int16) throws {
		try self.check(binding: sqlite3_bind_int64(self.prepared, 1, sqlite3_int64(value)))
	}

	mutating func encode(_ value: Int32) throws {
		try self.check(binding: sqlite3_bind_int64(self.prepared, 1, sqlite3_int64(value)))
	}

	mutating func encode(_ value: Int64) throws {
		try self.check(binding: sqlite3_bind_int64(self.prepared, 1, sqlite3_int64(value)))
	}

	mutating func encode(_ value: UInt) throws {
		try self.check(binding: sqlite3_bind_int64(self.prepared, 1, sqlite3_int64(value)))
	}

	mutating func encode(_ value: UInt8) throws {
		try self.check(binding: sqlite3_bind_int64(self.prepared, 1, sqlite3_int64(value)))
	}

	mutating func encode(_ value: UInt16) throws {
		try self.check(binding: sqlite3_bind_int64(self.prepared, 1, sqlite3_int64(value)))
	}

	mutating func encode(_ value: UInt32) throws {
		try self.check(binding: sqlite3_bind_int64(self.prepared, 1, sqlite3_int64(value)))
	}

	mutating func encode(_ value: UInt64) throws {
		try self.check(binding: sqlite3_bind_int64(self.prepared, 1, sqlite3_int64(value)))
	}

	mutating func encode<T>(_ value: T) throws where T : Encodable {
		let encodingContext = EncodingError.Context(codingPath: self.codingPath, debugDescription: "Unsupported encoding")
		throw EncodingError.invalidValue(value, encodingContext)
	}
}

struct SQLiteEncoder : Encoder {
	let codingPath: [CodingKey] = []
	let userInfo: [CodingUserInfoKey : Any] = [:]

	let prepared: OpaquePointer

	func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
		KeyedEncodingContainer(SQLiteKeyedEncodingContainer<Key>(prepared: self.prepared))
	}

	func unkeyedContainer() -> UnkeyedEncodingContainer {
		SQLiteUnkeyedEncodingContainer(prepared: self.prepared)
	}

	func singleValueContainer() -> SingleValueEncodingContainer {
		SQLiteSingleValueEncodingContainer(prepared: self.prepared)
	}
}

