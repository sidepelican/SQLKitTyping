public protocol IDModel: Model where Schema: IDSchemaProtocol, ID == Schema.ID {
    associatedtype ID
    var id: ID { get }
}
