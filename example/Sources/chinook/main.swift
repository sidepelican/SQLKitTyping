import SQLiteKit
import Logging
import Foundation

let exampleDBPath = Bundle.module.path(forResource: "chinook", ofType: "db")!
let tmpDBPath = NSTemporaryDirectory() + "\(UUID()).sqlite"
try FileManager.default.copyItem(atPath: exampleDBPath, toPath: tmpDBPath)
defer {
    try! FileManager.default.removeItem(atPath: tmpDBPath)
    print("cleanup finished.")
}

let source = SQLiteConnectionSource(
    configuration: .init(storage: .file(path: tmpDBPath))
)
let logger = Logger(label: "shinook")

let conn = try await source.makeConnection(logger: logger, on: MultiThreadedEventLoopGroup.singleton.next()).get()
let sql = conn.sql(queryLogLevel: .info)

try await example1(sql: sql)
try await example2(sql: sql)
try await example3(sql: sql)
try await example4(sql: sql)
try await example5(sql: sql)
try await example6(sql: sql)
try await example7(sql: sql)
try await example8(sql: sql)
try await example9(sql: sql)

try await conn.close().get()
