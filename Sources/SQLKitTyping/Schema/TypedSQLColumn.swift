import SQLKit

public struct TypedSQLColumn<Schema: SchemaProtocol, T>: SQLExpression, CustomStringConvertible, Sendable {
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

    public var withTable: Self {
        Self(name, serializeTable: true)
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
    public typealias Column<T> = TypedSQLColumn<Self, T> where T: Decodable
}

@attached(member, names: arbitrary, overloaded)
@attached(peer, names: suffixed(_types))
public macro Schema() = #externalMacro(module: "SQLKitTypingMacros", type: "Schema")
