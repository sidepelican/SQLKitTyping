public func group1<T>(@PropertyBuilder _ build: () -> PropertyBuilder.Result<T>) -> some PropertySQLExpression<GroupedProperty1<T>> {
    return GroupExpression<_>(expressions: build().columns)
}

public func group2<T>(@PropertyBuilder _ build: () -> PropertyBuilder.Result<T>) -> some PropertySQLExpression<GroupedProperty2<T>> {
    return GroupExpression<_>(expressions: build().columns)
}

public func group3<T>(@PropertyBuilder _ build: () -> PropertyBuilder.Result<T>) -> some PropertySQLExpression<GroupedProperty3<T>> {
    return GroupExpression<_>(expressions: build().columns)
}

public func group4<T>(@PropertyBuilder _ build: () -> PropertyBuilder.Result<T>) -> some PropertySQLExpression<GroupedProperty4<T>> {
    return GroupExpression<_>(expressions: build().columns)
}

public struct GroupedProperty1<Intersection: Decodable>: Decodable {
    public var group1: Intersection

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        group1 = try container.decode(Intersection.self)
    }
}

public struct GroupedProperty2<Intersection: Decodable>: Decodable {
    public var group2: Intersection

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        group2 = try container.decode(Intersection.self)
    }
}

public struct GroupedProperty3<Intersection: Decodable>: Decodable {
    public var group3: Intersection

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        group3 = try container.decode(Intersection.self)
    }
}

public struct GroupedProperty4<Intersection: Decodable>: Decodable {
    public var group4: Intersection

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        group4 = try container.decode(Intersection.self)
    }
}

fileprivate struct GroupExpression<Property: Decodable>: PropertySQLExpression {
    var expressions: [any SQLExpression]

    func serializeAsPropertySQLExpression(to serializer: inout SQLSerializer) {
        let separator = SQLRaw(", ")
        var iter = self.expressions.makeIterator()

        iter.next()?.serialize(to: &serializer)
        while let item = iter.next() {
            separator.serialize(to: &serializer)
            item.serialize(to: &serializer)
        }
    }
}
