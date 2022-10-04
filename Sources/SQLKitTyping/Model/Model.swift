public protocol Model: Decodable {
    associatedtype Schema: SchemaProtocol
}
