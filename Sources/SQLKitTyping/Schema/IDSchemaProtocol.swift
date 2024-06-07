public protocol IDSchemaProtocol: SchemaProtocol {
    associatedtype ID: IDType
    associatedtype IDColumn: TypedSQLColumn<Self, ID>
    static var id: IDColumn { get }
}
