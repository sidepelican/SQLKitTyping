public protocol IDModel: Model where Schema: IDSchemaProtocol {
    var id: Schema.ID { get }
}
