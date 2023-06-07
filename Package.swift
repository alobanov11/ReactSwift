// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "StoreSwift",
	platforms: [
		.iOS("13.0"),
	],
    products: [
        .library(name: "StoreSwift", targets: ["StoreSwift"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "StoreSwift",
            dependencies: [],
            path: "Sources"
        ),
    ]
)
