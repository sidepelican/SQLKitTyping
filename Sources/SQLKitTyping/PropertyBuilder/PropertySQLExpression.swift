import SQLKit

public protocol PropertySQLExpression<Property>: Sendable {
    associatedtype Property: Decodable
    func serializeAsPropertySQLExpression(to serializer: inout SQLSerializer)
}

extension PropertySQLExpression where Self: TypedSQLColumn {
    @usableFromInline var macroGeneratingCodingKeyName: String {
        "\(Schema.tableName)_\(name)"
    }

    @inlinable
    public func serializeAsPropertySQLExpression(to serializer: inout SQLSerializer) {
        SQLAlias(self.withTable, as: macroGeneratingCodingKeyName).serialize(to: &serializer)
    }

    @inlinable
    public func callAsFunction(_ expr: any SQLExpression) -> GenericExprTypedSQLColumn<Self, some SQLExpression> {
        .init(name: name, expr: SQLAlias(expr, as: macroGeneratingCodingKeyName))
    }
}

public struct GenericExprTypedSQLColumn<
    Base: TypedSQLColumn & PropertySQLExpression,
    Expr: SQLExpression
>: TypedSQLColumn, PropertySQLExpression {
    public typealias Schema = Base.Schema
    public typealias Value = Base.Value
    public typealias Property = Base.Property

    public var name: String

    @inlinable
    public init(name: String, expr: Expr) {
        self.name = name
        self.expr = expr
    }

    @usableFromInline
    var expr: Expr

    @inlinable
    public func serialize(to serializer: inout SQLSerializer) {
        expr.serialize(to: &serializer)
    }

    @inlinable
    public func serializeAsPropertySQLExpression(to serializer: inout SQLSerializer)  {
        expr.serialize(to: &serializer)
    }
}

public struct PropertySQLExpressionAsSQLExpression<Base: PropertySQLExpression>: SQLExpression {
    @inlinable
    public init(_ base: Base) {
        self.base = base
    }
    public var base: Base

    @inlinable
    public func serialize(to serializer: inout SQLSerializer) {
        base.serializeAsPropertySQLExpression(to: &serializer)
    }
}
