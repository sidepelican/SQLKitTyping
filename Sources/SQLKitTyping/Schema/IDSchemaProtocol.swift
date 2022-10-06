public protocol IDSchemaProtocol: SchemaProtocol {
    associatedtype ID: IDType
    static var id: Column<ID> { get }
}
