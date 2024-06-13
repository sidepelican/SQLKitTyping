// swift-tools-version: 5.10

import PackageDescription

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
    name: "example",
    platforms: [.macOS(.v12)],
    dependencies: [
        .package(path: "../"),
        .package(url: "https://github.com/vapor/sqlite-kit.git", from: "4.0.0"),
    ],
    targets: [
        .executableTarget(
            name: "example",
            dependencies: [
                .product(name: "SQLKitTyping", package: "SQLKitTyping"),
                .product(name: "SQLiteKit", package: "sqlite-kit"),
            ],
            resources: [.process("chinook.db")]
        ),
    ]
)
