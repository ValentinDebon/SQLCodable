# SQLCodable

Manipulate SQL databases using the SQL language. And interface with Swift using Codable and Combine.

## Why?

In Swift, lots of ORMs and bindings exists. But none of them allows you to write raw SQL and directly interface with the database.
SQLCodable provides an Opaque Interface to the database and statement management. It doesn't manage nested containers, but encodes
your type in a prepared statement, and decodes each row using the parameters/columns names.
