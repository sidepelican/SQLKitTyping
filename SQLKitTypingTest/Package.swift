// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "SQLKitTypingTest",
    platforms: [.macOS(.v12)],
    products: [
    ],
    dependencies: [
        .package(path: ".."),
        .package(url: "https://github.com/vapor/postgres-kit.git", from: "2.8.2"),
    ],
    targets: [
        .testTarget(
            name: "SQLKitTypingTests",
            dependencies: [
                .product(name: "PostgresKit", package: "postgres-kit"),
                "SQLKitTyping",
            ]
        ),
    ]
)
