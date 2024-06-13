import SQLKit

public final class SQLTypedReturningResultBuilder<Row: Decodable>: SQLTypedQueryFetcher {
    public var query: any SQLExpression
    public var database: any SQLDatabase
    @usableFromInline
    init(_ builder: some SQLReturningBuilder) {
        self.query = builder.query
        self.database = builder.database
    }
}

extension SQLReturningBuilder {
    @inlinable
    public func returningWithColumn<Expr: PropertySQLExpression>(_ column: Expr) -> SQLTypedReturningResultBuilder<Expr.Property> {
        self.returning = .init([PropertySQLExpressionAsSQLExpression(column)])
        return SQLTypedReturningResultBuilder(self)
    }

    @inlinable
    public func returningWithColumn<Property>(_ column: AllPropertyExpression<some Any, Property>) -> SQLTypedReturningResultBuilder<Property> {
        // INFO: TABLE.* cannot use in returning clause.
        self.returning = .init([SQLLiteral.all])
        return SQLTypedReturningResultBuilder(self)
    }

    @inlinable
    public func returningWithColumns<T>(@PropertyBuilder _ build: () -> PropertyBuilder.Result<T>) -> SQLTypedReturningResultBuilder<T> {
        self.returning = .init(build().columns)
        return SQLTypedReturningResultBuilder(self)
    }
}
