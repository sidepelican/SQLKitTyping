public protocol HasManyReference<Column, Property> {
    associatedtype Column: TypedSQLColumn where Column.Value: Hashable
    associatedtype Property
    associatedtype Model: Decodable
    static var column: Column { get }
    static var initProperty: ([Model]) -> Property { get }
}

public protocol HasOneReference<Property> {
    associatedtype Property
    associatedtype Model: Decodable & IDSchemaProtocol
    static var initProperty: (Model) -> Property { get }
}
