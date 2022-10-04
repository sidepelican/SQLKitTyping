@preconcurrency import SQLKit

public struct TypedSQLColumn<Schema: SchemaProtocol, T: Decodable>: SQLExpression, Sendable, CustomStringConvertible {
    public var name: SQLIdentifier
    public var serializeTable: Bool

    public init(_ name: String, serializeTable: Bool = false) {
        self.name = SQLIdentifier(name)
        self.serializeTable = serializeTable
    }

    public init(_ name: SQLIdentifier, serializeTable: Bool = false) {
        self.name = name
        self.serializeTable = serializeTable
    }

    public func serialize(to serializer: inout SQLSerializer) {
        if serializeTable {
            SQLIdentifier(Schema.tableName).serialize(to: &serializer)
            serializer.write(".")
        }
        name.serialize(to: &serializer)
    }

    public var withTable: Self {
        Self(name, serializeTable: true)
    }

    public var rawValue: String {
        name.string
    }

    public var description: String {
        rawValue
    }
}

extension SchemaProtocol {
    public typealias Column<T> = TypedSQLColumn<Self, T> where T: Decodable
}
