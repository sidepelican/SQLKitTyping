import SQLKit

public protocol SchemaProtocol: Codable {
    static var tableName: String { get }
}

extension SchemaProtocol {
    public var tableName: String { Self.tableName }
}
