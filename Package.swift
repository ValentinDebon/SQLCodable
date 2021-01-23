// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "SQLCodable",
	platforms: [ .macOS(.v10_15), ],
	products: [
		.library(
			name: "SQLCodable",
			targets: ["SQLCodable"]),
	],
	dependencies: [ ],
	targets: [
		.target(
			name: "CSQLite",
			dependencies: []),
		.target(
			name: "SQLCodable",
			dependencies: ["CSQLite"]),
		.testTarget(
			name: "SQLCodableTests",
			dependencies: ["SQLCodable"]),
	]
)
