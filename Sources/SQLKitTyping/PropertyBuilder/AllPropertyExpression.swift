import SQLKit

public struct AllPropertyExpression<Schema: SchemaProtocol, Property: Decodable>: PropertySQLExpression {
    @inlinable
    public init() {
    }

    @inlinable
    public var withTable: SQLAllColumn {
        SQLAllColumn(table: Schema.tableName, serializeTable: true)
    }

    @inlinable
    public func serializeAsPropertySQLExpression(to serializer: inout SQLSerializer) {
        self.withTable.serialize(to: &serializer)
    }
}
