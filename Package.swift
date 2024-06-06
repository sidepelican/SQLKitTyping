// swift-tools-version: 5.9

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "SQLKitTyping",
    platforms: [.macOS(.v12)],
    products: [
        .library(name: "SQLKitTyping", targets: ["SQLKitTyping"]),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/sql-kit.git", from: "3.30.0"),
        .package(url: "https://github.com/apple/swift-syntax.git", from: "510.0.2"),
    ],
    targets: [
        .macro(
            name: "SQLKitTypingMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            ]
        ),
        .target(
            name: "SQLKitTyping",
            dependencies: [
                .product(name: "SQLKit", package: "sql-kit"),
                "SQLKitTypingMacros",
            ]
        ),
        .testTarget(
            name: "SQLKitTypingMacroTests",
            dependencies: [
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
                "SQLKitTypingMacros",
                "SQLKitTyping",
            ]
        ),
    ]
)
