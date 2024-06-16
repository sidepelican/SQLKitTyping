public protocol ChildrenReference<Column, Property> {
    associatedtype Column: TypedSQLColumn where Column.Value: Equatable
    associatedtype Property: ChildrenProperty<Child>
    associatedtype Child: Decodable
    var column: Column { get }
    var initProperty: ([Child]) -> Property { get }
}

public protocol ChildrenProperty<Child> {
    associatedtype Child: Decodable
}

public struct GenericReference<
    Column: TypedSQLColumn,
    Property: ChildrenProperty & Decodable
>: ChildrenReference where Column.Value: Equatable {
    public init(column: Column, initProperty: @escaping ([Property.Child]) -> Property) {
        self.column = column
        self.initProperty = initProperty
    }
    
    public typealias Child = Property.Child
    public var column: Column
    public var initProperty: ([Property.Child]) -> Property
}
