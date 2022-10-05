import SQLKit

public protocol SchemaProtocol: SQLExpression, Sendable {
    static var tableName: String { get }
}

extension SchemaProtocol {
    public var tableName: String { Self.tableName }
}

extension SchemaProtocol {
    public func serialize(to serializer: inout SQLSerializer) {
        SQLIdentifier(tableName).serialize(to: &serializer)
    }
}
