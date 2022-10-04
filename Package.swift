// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "SQLKitTyping",
    platforms: [.macOS(.v12)],
    products: [
        .library(name: "SQLKitTyping", targets: ["SQLKitTyping"]),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/sql-kit.git", from: "3.0.0"),
    ],
    targets: [
        .target(
            name: "SQLKitTyping",
            dependencies: [
                .product(name: "SQLKit", package: "sql-kit"),
            ]
        ),
    ]
)
