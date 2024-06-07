import SQLKit

public protocol TypedSQLColumn<Schema, Value>: SQLExpression, Sendable {
    associatedtype Schema: SchemaProtocol
    associatedtype Value: Codable & Sendable
    var name: String { get }
}

public struct LegacyTypedSQLColumn<Schema: SchemaProtocol, Value: Codable & Sendable>: TypedSQLColumn, CustomStringConvertible {
    public var name: String
    public var serializeTable: Bool

    public init(_ name: String, serializeTable: Bool = false) {
        self.name = name
        self.serializeTable = serializeTable
    }

    public init(_ name: SQLIdentifier, serializeTable: Bool = false) {
        self.name = name.string
        self.serializeTable = serializeTable
    }

    public func serialize(to serializer: inout SQLSerializer) {
        if serializeTable {
            SQLIdentifier(Schema.tableName).serialize(to: &serializer)
            serializer.write(".")
        }
        SQLIdentifier(name).serialize(to: &serializer)
    }

    @available(*, deprecated, renamed: "name", message: "deprecated because this is not RawRepresentable")
    public var rawValue: String {
        name
    }

    public var description: String {
        name
    }
}

extension SchemaProtocol {
    public typealias Column<T: Codable> = LegacyTypedSQLColumn<Self, T>
}

public struct TypedSQLColumnWithTable<Schema: SchemaProtocol, Value: Codable & Sendable>: TypedSQLColumn {
    public init(base: some TypedSQLColumn<Schema, Value>) {
        self.name = base.name
    }

    public var name: String

    public func serialize(to serializer: inout SQLSerializer) {
        SQLIdentifier(Schema.tableName).serialize(to: &serializer)
        serializer.write(".")
        SQLIdentifier(name).serialize(to: &serializer)
    }
}

extension TypedSQLColumn {
    public var withTable: TypedSQLColumnWithTable<Schema, Value> {
        TypedSQLColumnWithTable(base: self)
    }
}
