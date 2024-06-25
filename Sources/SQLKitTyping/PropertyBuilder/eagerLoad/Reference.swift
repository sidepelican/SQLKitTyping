public protocol ChildrenReference<Column, Property> {
    associatedtype Column: TypedSQLColumn where Column.Value: Equatable
    associatedtype Property
    associatedtype Child: Decodable
    var column: Column { get }
    var initProperty: ([Child]) -> Property { get }
}

public protocol ChildrenProperty<Child> {
    associatedtype Child: Decodable
}

public protocol ParentReference<Column, Property> {
    associatedtype Column: TypedSQLColumn where Column.Value: Equatable
    associatedtype Property: ParentProperty<Parent>
    associatedtype Parent: Decodable
    var column: Column { get }
    var initProperty: (Parent) -> Property { get }
}

public protocol ParentProperty<Parent> {
    associatedtype Parent: Decodable
}

public struct _ParentReference<
    Column: TypedSQLColumn,
    Property: ParentProperty & Decodable
>: ParentReference where Column.Value: Equatable {
    public init(column: Column, initProperty: @escaping (Property.Parent) -> Property) {
        self.column = column
        self.initProperty = initProperty
    }

    public typealias Child = Property.Parent
    public var column: Column
    public var initProperty: (Property.Parent) -> Property
}
