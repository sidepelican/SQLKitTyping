import SQLKit

extension SQLDatabase {
    func print() -> any SQLDatabase {
        PrintSQLDatabase(database: self)
    }
}

struct PrintSQLDatabase<T: SQLDatabase>: SQLDatabase {
    var database: T

    var logger: Logger { database.logger }
    var eventLoop: EventLoop { database.eventLoop }
    var version: SQLDatabaseReportedVersion? { database.version }
    var dialect: SQLDialect { database.dialect }

    func execute(sql query: SQLExpression, _ onRow: @escaping (SQLRow) -> ()) -> EventLoopFuture<Void> {
        let (sql, binds) = serialize(query)
        if binds.isEmpty {
            Swift.print("\(sql)")
        } else {
            Swift.print("\(sql) \(binds)")
        }
        return database.execute(sql: query, onRow)
    }
}
