import SQLKit

public protocol SchemaProtocol {
    static var tableName: String { get }
}

extension SchemaProtocol {
    public var tableName: String { Self.tableName }
}
