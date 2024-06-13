import SQLKit

extension SQLDatabase {
    @inlinable
    public func create<Schema: SchemaProtocol>(table schema: Schema.Type) -> SQLCreateTableBuilder {
        return self.create(table: SQLIdentifier(schema.tableName))
    }

    @inlinable
    public func insert<Schema: SchemaProtocol>(into schema: Schema.Type) -> SQLInsertBuilder {
        return self.insert(into: SQLIdentifier(schema.tableName))
    }

    @inlinable
    public func delete<Schema: SchemaProtocol>(from schema: Schema.Type) -> SQLDeleteBuilder {
        return self.delete(from: SQLIdentifier(schema.tableName))
    }

    @inlinable
    public func drop<Schema: SchemaProtocol>(table schema: Schema.Type) -> SQLDropTableBuilder {
        return self.drop(table: SQLIdentifier(schema.tableName))
    }

    @inlinable
    public func update<Schema: SchemaProtocol>(_ schema: Schema.Type) -> SQLUpdateBuilder {
        return self.update(SQLIdentifier(schema.tableName))
    }
}

extension SQLSubqueryClauseBuilder {
    @inlinable
    @discardableResult
    public func from<Schema: SchemaProtocol>(_ schema: Schema.Type) -> Self {
        return self.from(SQLIdentifier(schema.tableName))
    }
}

public enum SQLNullsOrder: String {
    case first = "FIRST"
    case last = "LAST"
}

extension SQLPartialResultBuilder {
    public func orderBy(_ column: some TypedSQLColumn<some Any, some Comparable>, _ direction: SQLDirection) -> Self {
        orderBy(SQLOrderBy(expression: column, direction: direction))
    }

    public func orderBy(_ column: some TypedSQLColumn<some Any, (some Comparable)?>, _ direction: SQLDirection, nulls: SQLNullsOrder? = nil) -> Self {
        if let nulls {
            orderBy(SQLQueryString("\(SQLOrderBy(expression: column, direction: direction)) NULLS \(unsafeRaw: nulls.rawValue)"))
        } else {
            orderBy(SQLOrderBy(expression: column, direction: direction))
        }
    }
}

extension SQLQueryFetcher {
    public func first<each C: TypedSQLColumn>(
        decodingColumns column: repeat each C
    ) async throws -> (repeat (each C).Value)? {
        if let partialBuilder = self as? (any SQLPartialResultBuilder & SQLQueryFetcher) {
            return try await partialBuilder.limit(1).all(decodingColumns: repeat each column).first
        } else {
            return try await all(decodingColumns: repeat each column).first
        }
    }

    public func all<each C: TypedSQLColumn>(
        decodingColumns column: repeat each C
    ) async throws -> [(repeat (each C).Value)] {
        let rows = try await self.all()

        return try rows.map { row in
            func rowDecode<V>(row: any SQLRow, column: some TypedSQLColumn<some Any, V>) throws -> V {
                try row.decode(column: column.name, as: V.self)
            }
            return try (repeat rowDecode(row: row, column: each column))
        }
    }
}

extension SQLPredicateBuilder {
    @inlinable
    @discardableResult
    public func `where`<S, E>(_ lhs: some TypedSQLColumn<S, E>, _ op: SQLBinaryOperator, _ rhs: E) -> Self
    where E: Encodable
    {
        return self.where(lhs, op, SQLBind(rhs))
    }

    @inlinable
    @discardableResult
    public func `where`<S, E>(_ lhs: some TypedSQLColumn<S, E>, _ op: SQLBinaryOperator, _ rhs: [E]) -> Self
    where E: Encodable
    {
        return self.where(lhs, op, SQLBind.group(rhs))
    }
    
    @inlinable
    @discardableResult
    public func orWhere<S, E>(_ lhs: some TypedSQLColumn<S, E>, _ op: SQLBinaryOperator, _ rhs: E) -> Self
    where E: Encodable
    {
        return self.orWhere(lhs, op, SQLBind(rhs))
    }

    @inlinable
    @discardableResult
    public func orWhere<S, E>(_ lhs: some TypedSQLColumn<S, E>, _ op: SQLBinaryOperator, _ rhs: [E]) -> Self
    where E: Encodable
    {
        return self.orWhere(lhs, op, SQLBind.group(rhs))
    }
}

extension SQLJoinBuilder {
    @inlinable
    @discardableResult
    public func join<S: SchemaProtocol, T, S2>(
        _ table: S.Type,
        method: any SQLExpression = SQLJoinMethod.inner,
        on left: some TypedSQLColumn<S2, T>,
        _ op: SQLBinaryOperator,
        _ right: some TypedSQLColumn<S, T>
    ) -> Self {
        self.join(SQLIdentifier(table.tableName), method: method, on: left.withTable, op, right.withTable)
    }

    @inlinable
    @discardableResult
    public func join<S: SchemaProtocol, T, S2>(
        _ table: S.Type,
        method: any SQLExpression = SQLJoinMethod.inner,
        on left: some TypedSQLColumn<S2, T?>,
        _ op: SQLBinaryOperator,
        _ right: some TypedSQLColumn<S, T>
    ) -> Self {
        self.join(SQLIdentifier(table.tableName), method: method, on: left.withTable, op, right.withTable)
    }
}

extension SQLInsertBuilder {
    @discardableResult
    public func columnAndValues<each C: TypedSQLColumn>(
        _ columnAndValue: repeat (each C, (each C).Value)
    ) -> Self {
        var columns: [any SQLExpression] = []
        var values: [SQLBind] = []
        func set(column: String, value: some (Encodable & Sendable)) {
            columns.append(SQLIdentifier(column))
            values.append(SQLBind(value))
        }
        repeat set(column: (each columnAndValue).0.name, value: (each columnAndValue).1)

        self.columns(columns)
        self.values(values)
        return self
    }

    @discardableResult
    public func columnsAndValues<each C: TypedSQLColumn>(
        columns: repeat each C,
        values: [(repeat (each C).Value)]
    ) -> Self {
        var sumColumns: [String] = []
        repeat sumColumns.append((each columns).name)
        self.columns(sumColumns)

        for value in values {
            var sumValues: [SQLBind] = []
            repeat sumValues.append(SQLBind(each value))
            self.values(sumValues)
        }

        return self
    }
}

extension SQLColumnUpdateBuilder {
    @inlinable
    @discardableResult
    public func set<S, E>(_ column: some TypedSQLColumn<S, E>, to bind: E) -> Self
    where E: Encodable
    {
        return self.set(column, to: SQLBind(bind))
    }
}

extension SchemaProtocol {
    @inlinable
    public static var all: SQLAllColumn {
        SQLAllColumn(table: Self.tableName)
    }

    @available(*, deprecated, renamed: "all.withTable")
    public static var allWithTable: SQLColumn {
        SQLColumn(SQLLiteral.all, table: SQLIdentifier(Self.tableName))
    }
}

extension SQLRow {
    @inlinable
    public func decode<D: Decodable>(typed column: some TypedSQLColumn<some Any, D>) throws -> D {
        try decode(column: column.name, as: D.self)
    }

    @inlinable
    public func decode<D: Decodable>(typed column: some TypedSQLColumn<some Any, D>, alias: String) throws -> D {
        try decode(column: alias, as: D.self)
    }
}
