import XCTest
import PostgresKit
import Logging

extension PostgresConnection {
    static func test(on eventLoop: EventLoop) -> EventLoopFuture<PostgresConnection> {
        return PostgresConnectionSource(configuration: .test).makeConnection(logger: .init(label: "vapor.codes.postgres-kit.test"), on: eventLoop)
    }
}

extension PostgresConfiguration {
    static var test: Self {
        .init(
            hostname: env("POSTGRES_HOSTNAME") ?? "localhost",
            port: env("POSTGRES_PORT").flatMap(Int.init) ?? Self.ianaPortNumber,
            username: env("POSTGRES_USER") ?? "admin",
            password: env("POSTGRES_PASSWORD") ?? "admin",
            database: env("POSTGRES_DB") ?? "sqlkittyping_test",
            tlsConfiguration: nil
        )
    }
}

func env(_ name: String) -> String? {
    ProcessInfo.processInfo.environment[name]
}
