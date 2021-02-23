// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "SQLCodable",
	platforms: [ .macOS(.v10_15), .iOS(.v12), .linux ],
	products: [
		.library(
			name: "SQLCodable",
			targets: ["SQLCodable"]),
		.library(
			name: "SQLiteCodable",
			targets: ["SQLiteCodable"]),
	],
	dependencies: [ ],
	targets: [
		.target(
			name: "CSQLite",
			dependencies: []),
		.target(
			name: "SQLCodable",
			dependencies: []),
		.target(
			name: "SQLiteCodable",
			dependencies: ["CSQLite", "SQLCodable"]),
		.testTarget(
			name: "SQLCodableTests",
			dependencies: ["SQLiteCodable"]),
	]
)
