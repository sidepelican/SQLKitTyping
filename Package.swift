// swift-tools-version: 5.10

import PackageDescription
import CompilerPluginSupport

func swiftSettings(strictConcurrency: Bool = true, existentialAny: Bool = true) -> [SwiftSetting] {
    var settings: [SwiftSetting] = [
        .enableUpcomingFeature("ForwardTrailingClosures"),
        .enableUpcomingFeature("ConciseMagicFile"),
        .enableUpcomingFeature("BareSlashRegexLiterals"),
    ]
    if existentialAny {
        settings.append(.enableUpcomingFeature("ExistentialAny"))
    }
    if strictConcurrency {
        settings.append(.enableExperimentalFeature("StrictConcurrency"))
    }
    return settings
}

let package = Package(
    name: "SQLKitTyping",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "SQLKitTyping", targets: ["SQLKitTyping"]),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/sql-kit.git", from: "3.30.0"),
        .package(url: "https://github.com/swiftlang/swift-syntax.git", "600.0.0"..<"999.0.0"),
    ],
    targets: [
        .macro(
            name: "SQLKitTypingMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            ],
            swiftSettings: swiftSettings()
        ),
        .target(
            name: "SQLKitTyping",
            dependencies: [
                .product(name: "SQLKit", package: "sql-kit"),
                "SQLKitTypingMacros",
            ],
            swiftSettings: swiftSettings()
        ),
        .testTarget(
            name: "SQLKitTypingMacroTests",
            dependencies: [
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
                "SQLKitTypingMacros",
                "SQLKitTyping",
            ],
            swiftSettings: swiftSettings()
        ),
    ]
)
