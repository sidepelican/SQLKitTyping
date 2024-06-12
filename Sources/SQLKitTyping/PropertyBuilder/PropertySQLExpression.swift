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
    public func callAsFunction(_ expr: any SQLExpression) -> GenericColumnExpression<Self.Property, some SQLExpression> {
        .init(expr: SQLAlias(expr, as: macroGeneratingCodingKeyName))
    }
}

public struct GenericColumnExpression<Property: Decodable, Expr: SQLExpression>: PropertySQLExpression {
    @inlinable
    public init(expr: Expr) {
        self.expr = expr
    }

    @usableFromInline
    var expr: Expr

    public func serializeAsPropertySQLExpression(to serializer: inout SQLSerializer)  {
        expr.serialize(to: &serializer)
    }
}

public struct NullableColumnExpression<Base: PropertySQLExpression>: PropertySQLExpression {
    @inlinable
    public init(base: Base) {
        self.base = base
    }

    @dynamicMemberLookup
    public struct Property: Decodable {
        public var wrapped: Base.Property?

        public init(from decoder: any Decoder) throws {
            let container = try decoder.singleValueContainer()
            do {
                wrapped = try container.decode(Base.Property.self)
            } catch let error as DecodingError {
                if case .valueNotFound = error {
                    wrapped = nil
                }
            }
        }

        @inlinable
        public subscript<T>(dynamicMember keyPath: KeyPath<Base.Property, T>) -> T? {
            wrapped?[keyPath: keyPath]
        }
    }

    @usableFromInline
    var base: Base

    public func serializeAsPropertySQLExpression(to serializer: inout SQLSerializer)  {
        base.serializeAsPropertySQLExpression(to: &serializer)
    }
}

extension PropertySQLExpression where Self.Property: Decodable {
    @inlinable
    public var nullable: NullableColumnExpression<Self> {
        NullableColumnExpression(base: self)
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
