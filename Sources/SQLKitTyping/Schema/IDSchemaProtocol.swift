public protocol IDSchemaProtocol: SchemaProtocol {
    associatedtype ID: IDType
    var id: Column<ID> { get }
}
