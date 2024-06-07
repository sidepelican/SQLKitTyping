public protocol IDSchemaProtocol: SchemaProtocol {
    associatedtype ID: IDType = IDColumn.Value
    associatedtype IDColumn: TypedSQLColumn<Self, ID>
    static var id: IDColumn { get }
}
