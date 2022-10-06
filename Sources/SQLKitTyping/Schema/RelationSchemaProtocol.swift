import Foundation

public protocol RelationSchemaProtocol: SchemaProtocol {
    associatedtype ID1: IDType
    associatedtype ID2: IDType
    static var relation: PivotJoinRelation<Self, ID1, ID2> { get }
}

public struct PivotJoinRelation<RelationSchema: SchemaProtocol,
                                FromID: IDType,
                                ToID: IDType> {
    public var from: TypedSQLColumn<RelationSchema, FromID>
    public var to: TypedSQLColumn<RelationSchema, ToID>
    public init(
        from: TypedSQLColumn<RelationSchema, FromID>,
        to: TypedSQLColumn<RelationSchema, ToID>
    ) {
        self.from = from
        self.to = to
    }

    public var swapped: PivotJoinRelation<RelationSchema, ToID, FromID> {
        .init(from: to, to: from)
    }
}
