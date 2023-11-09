import SQLKit

public struct SQLAllColumn: SQLExpression {
    public var table: String
    public var serializeTable: Bool

    @inlinable
    public init(table: String, serializeTable: Bool = false) {
        self.table = table
        self.serializeTable = serializeTable
    }

    @inlinable
    public var withTable: Self {
        Self(table: table,  serializeTable: true)
    }

    @inlinable
    public func serialize(to serializer: inout SQLSerializer) {
        if serializeTable {
            SQLIdentifier(table).serialize(to: &serializer)
            serializer.write(".")
        }
        SQLLiteral.all.serialize(to: &serializer)
    }
}
