import SQLKit

public final class SQLTypedSelectBuilder<Row: Decodable>: SQLQueryBuilder, SQLTypedQueryFetcher, SQLSubqueryClauseBuilder {
    public var select: SQLSelect

    public var database: any SQLDatabase

    @inlinable
    public var query: any SQLExpression {
        self.select
    }

    @inlinable
    public init(on database: any SQLDatabase) {
        self.select = .init()
        self.database = database
    }
}

extension SQLDatabase {
    @available(*, unavailable, message: ".withTable cannot use here")
    public func selectWithColumn(_ column: SQLAllColumn) -> SQLSelectBuilder {
        fatalError()
    }

    @inlinable
    public func selectWithColumn<Expr: PropertySQLExpression>(_ column: Expr) -> SQLTypedSelectBuilder<Expr.Property> {
        let builder = SQLTypedSelectBuilder<Expr.Property>(on: self)
        builder.column(PropertySQLExpressionAsSQLExpression(column))
        return builder
    }

    @inlinable
    public func selectWithColumns<T>(@PropertyBuilder _ build: () -> PropertyBuilder.Result<T>) -> SQLTypedSelectBuilder<T> {
        let builder = SQLTypedSelectBuilder<T>(on: self)
        builder.columns(build().columns)
        return builder
    }
}
