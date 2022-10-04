public protocol SchemaProtocol: Sendable {
    static var tableName: String { get }
}

extension SchemaProtocol {
    var tableName: String { Self.tableName }
}
