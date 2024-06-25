public protocol HasManyReference<Column, Property> {
    associatedtype Column: TypedSQLColumn where Column.Value: Hashable
    associatedtype Property
    associatedtype Model: Decodable
    var column: Column { get }
    var initProperty: ([Model]) -> Property { get }
}

public protocol HasOneReference<Column, Property> {
    associatedtype Column: TypedSQLColumn where Column.Value: Hashable
    associatedtype Property
    associatedtype Model: Decodable
    var column: Column { get }
    var initProperty: (Model) -> Property { get }
}
