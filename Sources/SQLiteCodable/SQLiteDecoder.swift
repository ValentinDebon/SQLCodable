import CSQLite

fileprivate struct SQLiteKeyedDecodingContainer<Key> : KeyedDecodingContainerProtocol where Key : CodingKey {
	private let indices: [String : Int32]

	let codingPath: [CodingKey] = []
	let allKeys: [Key] = []

	let prepared: OpaquePointer

	init(prepared: OpaquePointer) {
		var indices = [String : Int32]()

		for index in 0..<Int32(sqlite3_column_count(prepared)) {
			guard let cString = sqlite3_column_name(prepared, index) else {
				fatalError("sqlite3_column_name: Not enough memory")
			}

			indices[String(cString: cString)] = index
		}

		self.indices = indices
		self.prepared = prepared
	}

	private func check<T>(type: Int32, forKey key: Key, column: @escaping(OpaquePointer, Int32) -> T) throws -> T {
		guard let keyIndex = self.indices.index(forKey: key.stringValue) else {
			let decodingContext = DecodingError.Context(codingPath: self.codingPath, debugDescription: "Invalid Key")
			throw DecodingError.keyNotFound(key, decodingContext)
		}

		let index = self.indices[keyIndex].value
		guard sqlite3_column_type(self.prepared, index) == type else {
			let decodingContext = DecodingError.Context(codingPath: self.codingPath, debugDescription: "Invalid type")
			throw DecodingError.typeMismatch(T.self, decodingContext)
		}

		return column(self.prepared, index)
	}

	func contains(_ key: Key) -> Bool {
		self.indices.index(forKey: key.stringValue) != nil
	}

	func decodeNil(forKey key: Key) throws -> Bool {
		guard let keyIndex = self.indices.index(forKey: key.stringValue) else {
			let decodingContext = DecodingError.Context(codingPath: self.codingPath, debugDescription: "Invalid Key")
			throw DecodingError.keyNotFound(key, decodingContext)
		}

		return sqlite3_column_type(self.prepared, self.indices[keyIndex].value) == SQLITE_NULL
	}

	func decode(_ type: Bool.Type, forKey key: Key) throws -> Bool {
		try self.check(type: SQLITE_INTEGER, forKey: key) { sqlite3_column_int64($0, $1) != 0 }
	}

	func decode(_ type: String.Type, forKey key: Key) throws -> String {
		let text = try self.check(type: SQLITE_TEXT, forKey: key) { sqlite3_column_text($0, $1) }

		guard let cString = text else {
			let decodingContext = DecodingError.Context(codingPath: self.codingPath, debugDescription: "Invalid String nil value")
			throw DecodingError.valueNotFound(type, decodingContext)
		}

		return String(cString: cString)
	}

	func decode(_ type: Double.Type, forKey key: Key) throws -> Double {
		try self.check(type: SQLITE_FLOAT, forKey: key) { sqlite3_column_double($0, $1) }
	}

	func decode(_ type: Float.Type, forKey key: Key) throws -> Float {
		try self.check(type: SQLITE_FLOAT, forKey: key) { Float(sqlite3_column_double($0, $1)) }
	}

	func decode(_ type: Int.Type, forKey key: Key) throws -> Int {
		try self.check(type: SQLITE_INTEGER, forKey: key) { Int(sqlite3_column_int64($0, $1)) }
	}

	func decode(_ type: Int8.Type, forKey key: Key) throws -> Int8 {
		try self.check(type: SQLITE_INTEGER, forKey: key) { Int8(sqlite3_column_int64($0, $1)) }
	}

	func decode(_ type: Int16.Type, forKey key: Key) throws -> Int16 {
		try self.check(type: SQLITE_INTEGER, forKey: key) { Int16(sqlite3_column_int64($0, $1)) }
	}

	func decode(_ type: Int32.Type, forKey key: Key) throws -> Int32 {
		try self.check(type: SQLITE_INTEGER, forKey: key) { Int32(sqlite3_column_int64($0, $1)) }
	}

	func decode(_ type: Int64.Type, forKey key: Key) throws -> Int64 {
		try self.check(type: SQLITE_INTEGER, forKey: key) { Int64(sqlite3_column_int64($0, $1)) }
	}

	func decode(_ type: UInt.Type, forKey key: Key) throws -> UInt {
		try self.check(type: SQLITE_INTEGER, forKey: key) { UInt(sqlite3_column_int64($0, $1)) }
	}

	func decode(_ type: UInt8.Type, forKey key: Key) throws -> UInt8 {
		try self.check(type: SQLITE_INTEGER, forKey: key) { UInt8(sqlite3_column_int64($0, $1)) }
	}

	func decode(_ type: UInt16.Type, forKey key: Key) throws -> UInt16 {
		try self.check(type: SQLITE_INTEGER, forKey: key) { UInt16(sqlite3_column_int64($0, $1)) }
	}

	func decode(_ type: UInt32.Type, forKey key: Key) throws -> UInt32 {
		try self.check(type: SQLITE_INTEGER, forKey: key) { UInt32(sqlite3_column_int64($0, $1)) }
	}

	func decode(_ type: UInt64.Type, forKey key: Key) throws -> UInt64 {
		try self.check(type: SQLITE_INTEGER, forKey: key) { UInt64(sqlite3_column_int64($0, $1)) }
	}

	func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T : Decodable {
		// TODO
		let decodingContext = DecodingError.Context(codingPath: self.codingPath, debugDescription: "Unsupported decoding at key \(key)")
		throw DecodingError.typeMismatch(type, decodingContext)
	}

	func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
		fatalError()
	}

	func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
		fatalError()
	}

	func superDecoder() throws -> Decoder {
		fatalError()
	}

	func superDecoder(forKey key: Key) throws -> Decoder {
		fatalError()
	}
}

fileprivate struct SQLiteUnkeyedDecodingContainer : UnkeyedDecodingContainer {
	private let indices: Range<Int>

	private(set) var currentIndex = 0

	let codingPath: [CodingKey] = []

	let prepared: OpaquePointer

	init(prepared: OpaquePointer) {
		self.indices = 0..<Int(sqlite3_column_count(prepared))
		self.prepared = prepared
	}

	var count: Int? {
		self.indices.upperBound
	}

	var isAtEnd: Bool {
		self.currentIndex == self.indices.upperBound
	}

	private mutating func check<T>(type: Int32, column: @escaping(OpaquePointer, Int32) -> T) throws -> T {
		guard self.indices.contains(self.currentIndex), sqlite3_column_type(self.prepared, Int32(self.currentIndex)) == type else {
			let decodingContext = DecodingError.Context(codingPath: self.codingPath, debugDescription: "Invalid type")
			throw DecodingError.typeMismatch(T.self, decodingContext)
		}

		defer { self.currentIndex += 1 }

		return column(self.prepared, Int32(self.currentIndex))
	}

	mutating func decodeNil() -> Bool {
		sqlite3_column_type(self.prepared, Int32(self.currentIndex)) == SQLITE_NULL
	}

	mutating func decode(_ type: Bool.Type) throws -> Bool {
		try self.check(type: SQLITE_INTEGER) { sqlite3_column_int64($0, $1) != 0 }
	}

	mutating func decode(_ type: String.Type) throws -> String {
		let text = try self.check(type: SQLITE_TEXT) { sqlite3_column_text($0, $1) }

		guard let cString = text else {
			self.currentIndex -= 1
			let decodingContext = DecodingError.Context(codingPath: self.codingPath, debugDescription: "Invalid String nil value")
			throw DecodingError.valueNotFound(type, decodingContext)
		}

		return String(cString: cString)
	}

	mutating func decode(_ type: Double.Type) throws -> Double {
		try self.check(type: SQLITE_FLOAT) { sqlite3_column_double($0, $1) }
	}

	mutating func decode(_ type: Float.Type) throws -> Float {
		try self.check(type: SQLITE_FLOAT) { Float(sqlite3_column_double($0, $1)) }
	}

	mutating func decode(_ type: Int.Type) throws -> Int {
		try self.check(type: SQLITE_INTEGER) { Int(sqlite3_column_int64($0, $1)) }
	}

	mutating func decode(_ type: Int8.Type) throws -> Int8 {
		try self.check(type: SQLITE_INTEGER) { Int8(sqlite3_column_int64($0, $1)) }
	}

	mutating func decode(_ type: Int16.Type) throws -> Int16 {
		try self.check(type: SQLITE_INTEGER) { Int16(sqlite3_column_int64($0, $1)) }
	}

	mutating func decode(_ type: Int32.Type) throws -> Int32 {
		try self.check(type: SQLITE_INTEGER) { Int32(sqlite3_column_int64($0, $1)) }
	}

	mutating func decode(_ type: Int64.Type) throws -> Int64 {
		try self.check(type: SQLITE_INTEGER) { Int64(sqlite3_column_int64($0, $1)) }
	}

	mutating func decode(_ type: UInt.Type) throws -> UInt {
		try self.check(type: SQLITE_INTEGER) { UInt(sqlite3_column_int64($0, $1)) }
	}

	mutating func decode(_ type: UInt8.Type) throws -> UInt8 {
		try self.check(type: SQLITE_INTEGER) { UInt8(sqlite3_column_int64($0, $1)) }
	}

	mutating func decode(_ type: UInt16.Type) throws -> UInt16 {
		try self.check(type: SQLITE_INTEGER) { UInt16(sqlite3_column_int64($0, $1)) }
	}

	mutating func decode(_ type: UInt32.Type) throws -> UInt32 {
		try self.check(type: SQLITE_INTEGER) { UInt32(sqlite3_column_int64($0, $1)) }
	}

	mutating func decode(_ type: UInt64.Type) throws -> UInt64 {
		try self.check(type: SQLITE_INTEGER) { UInt64(sqlite3_column_int64($0, $1)) }
	}

	mutating func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
		// TODO
		let decodingContext = DecodingError.Context(codingPath: self.codingPath, debugDescription: "Unsupported decoding")
		throw DecodingError.typeMismatch(type, decodingContext)
	}

	mutating func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
		fatalError()
	}

	mutating func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
		fatalError()
	}

	mutating func superDecoder() throws -> Decoder {
		fatalError()
	}
}

fileprivate struct SQLiteSingleValueDecodingContainer : SingleValueDecodingContainer {
	private let indices: Range<Int32>

	let codingPath: [CodingKey] = []

	let prepared: OpaquePointer

	init(prepared: OpaquePointer) {
		self.indices = 0..<sqlite3_column_count(prepared)
		self.prepared = prepared
	}

	private func check<T>(type: Int32, column: @escaping(OpaquePointer, Int32) -> T) throws -> T {
		guard self.indices.contains(0), sqlite3_column_type(self.prepared, 0) == type else {
			let decodingContext = DecodingError.Context(codingPath: self.codingPath, debugDescription: "Invalid type")
			throw DecodingError.typeMismatch(T.self, decodingContext)
		}

		return column(self.prepared, 0)
	}

	func decodeNil() -> Bool {
		sqlite3_column_type(self.prepared, 0) == SQLITE_NULL
	}

	func decode(_ type: Bool.Type) throws -> Bool {
		try self.check(type: SQLITE_INTEGER) { sqlite3_column_int64($0, $1) != 0 }
	}

	func decode(_ type: String.Type) throws -> String {
		let text = try self.check(type: SQLITE_TEXT) { sqlite3_column_text($0, $1) }

		guard let cString = text else {
			let decodingContext = DecodingError.Context(codingPath: self.codingPath, debugDescription: "Invalid String nil value")
			throw DecodingError.valueNotFound(type, decodingContext)
		}

		return String(cString: cString)
	}

	func decode(_ type: Double.Type) throws -> Double {
		try self.check(type: SQLITE_FLOAT) { sqlite3_column_double($0, $1) }
	}

	func decode(_ type: Float.Type) throws -> Float {
		try self.check(type: SQLITE_FLOAT) { Float(sqlite3_column_double($0, $1)) }
	}

	func decode(_ type: Int.Type) throws -> Int {
		try self.check(type: SQLITE_INTEGER) { Int(sqlite3_column_int64($0, $1)) }
	}

	func decode(_ type: Int8.Type) throws -> Int8 {
		try self.check(type: SQLITE_INTEGER) { Int8(sqlite3_column_int64($0, $1)) }
	}

	func decode(_ type: Int16.Type) throws -> Int16 {
		try self.check(type: SQLITE_INTEGER) { Int16(sqlite3_column_int64($0, $1)) }
	}

	func decode(_ type: Int32.Type) throws -> Int32 {
		try self.check(type: SQLITE_INTEGER) { Int32(sqlite3_column_int64($0, $1)) }
	}

	func decode(_ type: Int64.Type) throws -> Int64 {
		try self.check(type: SQLITE_INTEGER) { Int64(sqlite3_column_int64($0, $1)) }
	}

	func decode(_ type: UInt.Type) throws -> UInt {
		try self.check(type: SQLITE_INTEGER) { UInt(sqlite3_column_int64($0, $1)) }
	}

	func decode(_ type: UInt8.Type) throws -> UInt8 {
		try self.check(type: SQLITE_INTEGER) { UInt8(sqlite3_column_int64($0, $1)) }
	}

	func decode(_ type: UInt16.Type) throws -> UInt16 {
		try self.check(type: SQLITE_INTEGER) { UInt16(sqlite3_column_int64($0, $1)) }
	}

	func decode(_ type: UInt32.Type) throws -> UInt32 {
		try self.check(type: SQLITE_INTEGER) { UInt32(sqlite3_column_int64($0, $1)) }
	}

	func decode(_ type: UInt64.Type) throws -> UInt64 {
		try self.check(type: SQLITE_INTEGER) { UInt64(sqlite3_column_int64($0, $1)) }
	}

	func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
		// TODO
		let decodingContext = DecodingError.Context(codingPath: self.codingPath, debugDescription: "Unsupported decoding")
		throw DecodingError.typeMismatch(type, decodingContext)
	}
}

struct SQLiteDecoder : Decoder {
	let codingPath: [CodingKey] = []
	let userInfo: [CodingUserInfoKey : Any] = [:]

	let prepared: OpaquePointer

	func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
		KeyedDecodingContainer(SQLiteKeyedDecodingContainer<Key>(prepared: self.prepared))
	}

	func unkeyedContainer() throws -> UnkeyedDecodingContainer {
		SQLiteUnkeyedDecodingContainer(prepared: self.prepared)
	}

	func singleValueContainer() throws -> SingleValueDecodingContainer {
		SQLiteSingleValueDecodingContainer(prepared: self.prepared)
	}
}

