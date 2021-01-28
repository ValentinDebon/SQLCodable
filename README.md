# SQLCodable

Manipulate SQL databases using the SQL language. And interface with Swift using Codable.

## Why?

In Swift, lots of ORMs and bindings exists. But none of them allows you to write raw SQL and directly interface with the database.
SQLCodable provides an Opaque Interface to the database and statement management. It doesn't manage nested containers, but encodes
your type in a prepared statement, and decodes each row using the parameters/columns names.

## Example

Let's say you're a teacher and want to keep track of every students and the average of their marks for the semester.
The following sample illustrates how to create a DAO and interface for and SQLite-backed database.

```{swift}
import SQLiteCodable
import SQLCodable

struct Student : Codable {
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

	func add(student: Student) {
		try self.query("insert into students values (:firstname, :lastname, :average)", with: student).next()
	}

	func findStudent(firstname: String, lastname: String) -> Student? {
		try self.query("select * from students where firstname = ?1 and lastname = ?2", with: firstname, lastname).next()
	}

	func validStudents(minimum average: Double = 10.0) -> [Student] {
		try Array(self.query("select * from students where average >= ?1 order by average desc", with: average))
	}
}

let studentDAO = try StudentDAO(sqliteDatabase: SQLiteDatabase())

try studentDAO.add(student: Student(firstname: "Nino", lastname: "Quincampoix", average:  9.0))
try studentDAO.add(student: Student(firstname: "Raphaël", lastname: "Poulain", average: 7.0))
try studentDAO.add(student: Student(firstname: "Dominique", lastname: "Bretodeau", average: 12.0))
try studentDAO.add(student: Student(firstname: "Raymond", lastname: "Dufayel", average: 17.0))

try print(studentDAO.findStudent(firstname: "Dominique", lastname: "Bretodeau")!)
try print(studentDAO.validStudents())

```

