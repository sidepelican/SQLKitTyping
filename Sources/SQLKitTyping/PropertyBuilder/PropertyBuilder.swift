/*
for i in 2...12 {
    let e = """
    public static func buildBlock<
\((0..<i).map({ "C\($0): PropertySQLExpression" }).joined(separator: ", "))
    >(
        \((0..<i).map({ "c\($0): C\($0)" }).joined(separator: ", "))
    ) -> Result<Intersection\(i)<\((0..<i).map({ "C\($0)" }).joined(separator: ", "))>> {
        Result(
            columns: [\((0..<i).map({ "PropertySQLExpressionAsSQLExpression(c\($0))" }).joined(separator: ", "))]
        )
    }

"""
    print(e)
}
*/

@resultBuilder
public struct PropertyBuilder {
    public struct Result<T: Decodable> {
        public var columns: [any SQLExpression]
    }

    public static func buildBlock<
        C0: PropertySQLExpression
    >(
        _ c0: C0
    ) -> Result<C0.Property> {
        Result(
            columns: [PropertySQLExpressionAsSQLExpression(c0)]
        )
    }

    public static func buildBlock<
        C0: PropertySQLExpression, C1: PropertySQLExpression
    >(
        _ c0: C0, _ c1: C1
    ) -> Result<Intersection2<C0.Property, C1.Property>> {
        Result(
            columns: [PropertySQLExpressionAsSQLExpression(c0), PropertySQLExpressionAsSQLExpression(c1)]
        )
    }

    public static func buildBlock<
        C0: PropertySQLExpression, C1: PropertySQLExpression, C2: PropertySQLExpression
    >(
        _ c0: C0, _ c1: C1, _ c2: C2
    ) -> Result<Intersection3<C0.Property, C1.Property, C2.Property>> {
        Result(
            columns: [PropertySQLExpressionAsSQLExpression(c0), PropertySQLExpressionAsSQLExpression(c1), PropertySQLExpressionAsSQLExpression(c2)]
        )
    }

    public static func buildBlock<
        C0: PropertySQLExpression, C1: PropertySQLExpression, C2: PropertySQLExpression, C3: PropertySQLExpression
    >(
        _ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3
    ) -> Result<Intersection4<C0.Property, C1.Property, C2.Property, C3.Property>> {
        Result(
            columns: [PropertySQLExpressionAsSQLExpression(c0), PropertySQLExpressionAsSQLExpression(c1), PropertySQLExpressionAsSQLExpression(c2), PropertySQLExpressionAsSQLExpression(c3)]
        )
    }

    public static func buildBlock<
        C0: PropertySQLExpression, C1: PropertySQLExpression, C2: PropertySQLExpression, C3: PropertySQLExpression, C4: PropertySQLExpression
    >(
        _ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4
    ) -> Result<Intersection5<C0.Property, C1.Property, C2.Property, C3.Property, C4.Property>> {
        Result(
            columns: [PropertySQLExpressionAsSQLExpression(c0), PropertySQLExpressionAsSQLExpression(c1), PropertySQLExpressionAsSQLExpression(c2), PropertySQLExpressionAsSQLExpression(c3), PropertySQLExpressionAsSQLExpression(c4)]
        )
    }

    public static func buildBlock<
        C0: PropertySQLExpression, C1: PropertySQLExpression, C2: PropertySQLExpression, C3: PropertySQLExpression, C4: PropertySQLExpression, C5: PropertySQLExpression
    >(
        _ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4, _ c5: C5
    ) -> Result<Intersection6<C0.Property, C1.Property, C2.Property, C3.Property, C4.Property, C5.Property>> {
        Result(
            columns: [PropertySQLExpressionAsSQLExpression(c0), PropertySQLExpressionAsSQLExpression(c1), PropertySQLExpressionAsSQLExpression(c2), PropertySQLExpressionAsSQLExpression(c3), PropertySQLExpressionAsSQLExpression(c4), PropertySQLExpressionAsSQLExpression(c5)]
        )
    }

    public static func buildBlock<
        C0: PropertySQLExpression, C1: PropertySQLExpression, C2: PropertySQLExpression, C3: PropertySQLExpression, C4: PropertySQLExpression, C5: PropertySQLExpression, C6: PropertySQLExpression
    >(
        _ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4, _ c5: C5, _ c6: C6
    ) -> Result<Intersection7<C0.Property, C1.Property, C2.Property, C3.Property, C4.Property, C5.Property, C6.Property>> {
        Result(
            columns: [PropertySQLExpressionAsSQLExpression(c0), PropertySQLExpressionAsSQLExpression(c1), PropertySQLExpressionAsSQLExpression(c2), PropertySQLExpressionAsSQLExpression(c3), PropertySQLExpressionAsSQLExpression(c4), PropertySQLExpressionAsSQLExpression(c5), PropertySQLExpressionAsSQLExpression(c6)]
        )
    }

    public static func buildBlock<
        C0: PropertySQLExpression, C1: PropertySQLExpression, C2: PropertySQLExpression, C3: PropertySQLExpression, C4: PropertySQLExpression, C5: PropertySQLExpression, C6: PropertySQLExpression, C7: PropertySQLExpression
    >(
        _ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4, _ c5: C5, _ c6: C6, _ c7: C7
    ) -> Result<Intersection8<C0.Property, C1.Property, C2.Property, C3.Property, C4.Property, C5.Property, C6.Property, C7.Property>> {
        Result(
            columns: [PropertySQLExpressionAsSQLExpression(c0), PropertySQLExpressionAsSQLExpression(c1), PropertySQLExpressionAsSQLExpression(c2), PropertySQLExpressionAsSQLExpression(c3), PropertySQLExpressionAsSQLExpression(c4), PropertySQLExpressionAsSQLExpression(c5), PropertySQLExpressionAsSQLExpression(c6), PropertySQLExpressionAsSQLExpression(c7)]
        )
    }

    public static func buildBlock<
        C0: PropertySQLExpression, C1: PropertySQLExpression, C2: PropertySQLExpression, C3: PropertySQLExpression, C4: PropertySQLExpression, C5: PropertySQLExpression, C6: PropertySQLExpression, C7: PropertySQLExpression, C8: PropertySQLExpression
    >(
        _ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4, _ c5: C5, _ c6: C6, _ c7: C7, _ c8: C8
    ) -> Result<Intersection9<C0.Property, C1.Property, C2.Property, C3.Property, C4.Property, C5.Property, C6.Property, C7.Property, C8.Property>> {
        Result(
            columns: [PropertySQLExpressionAsSQLExpression(c0), PropertySQLExpressionAsSQLExpression(c1), PropertySQLExpressionAsSQLExpression(c2), PropertySQLExpressionAsSQLExpression(c3), PropertySQLExpressionAsSQLExpression(c4), PropertySQLExpressionAsSQLExpression(c5), PropertySQLExpressionAsSQLExpression(c6), PropertySQLExpressionAsSQLExpression(c7), PropertySQLExpressionAsSQLExpression(c8)]
        )
    }

    public static func buildBlock<
        C0: PropertySQLExpression, C1: PropertySQLExpression, C2: PropertySQLExpression, C3: PropertySQLExpression, C4: PropertySQLExpression, C5: PropertySQLExpression, C6: PropertySQLExpression, C7: PropertySQLExpression, C8: PropertySQLExpression, C9: PropertySQLExpression
    >(
        _ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4, _ c5: C5, _ c6: C6, _ c7: C7, _ c8: C8, _ c9: C9
    ) -> Result<Intersection10<C0.Property, C1.Property, C2.Property, C3.Property, C4.Property, C5.Property, C6.Property, C7.Property, C8.Property, C9.Property>> {
        Result(
            columns: [PropertySQLExpressionAsSQLExpression(c0), PropertySQLExpressionAsSQLExpression(c1), PropertySQLExpressionAsSQLExpression(c2), PropertySQLExpressionAsSQLExpression(c3), PropertySQLExpressionAsSQLExpression(c4), PropertySQLExpressionAsSQLExpression(c5), PropertySQLExpressionAsSQLExpression(c6), PropertySQLExpressionAsSQLExpression(c7), PropertySQLExpressionAsSQLExpression(c8), PropertySQLExpressionAsSQLExpression(c9)]
        )
    }

    public static func buildBlock<
        C0: PropertySQLExpression, C1: PropertySQLExpression, C2: PropertySQLExpression, C3: PropertySQLExpression, C4: PropertySQLExpression, C5: PropertySQLExpression, C6: PropertySQLExpression, C7: PropertySQLExpression, C8: PropertySQLExpression, C9: PropertySQLExpression, C10: PropertySQLExpression
    >(
        _ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4, _ c5: C5, _ c6: C6, _ c7: C7, _ c8: C8, _ c9: C9, _ c10: C10
    ) -> Result<Intersection11<C0.Property, C1.Property, C2.Property, C3.Property, C4.Property, C5.Property, C6.Property, C7.Property, C8.Property, C9.Property, C10.Property>> {
        Result(
            columns: [PropertySQLExpressionAsSQLExpression(c0), PropertySQLExpressionAsSQLExpression(c1), PropertySQLExpressionAsSQLExpression(c2), PropertySQLExpressionAsSQLExpression(c3), PropertySQLExpressionAsSQLExpression(c4), PropertySQLExpressionAsSQLExpression(c5), PropertySQLExpressionAsSQLExpression(c6), PropertySQLExpressionAsSQLExpression(c7), PropertySQLExpressionAsSQLExpression(c8), PropertySQLExpressionAsSQLExpression(c9), PropertySQLExpressionAsSQLExpression(c10)]
        )
    }

    public static func buildBlock<
        C0: PropertySQLExpression, C1: PropertySQLExpression, C2: PropertySQLExpression, C3: PropertySQLExpression, C4: PropertySQLExpression, C5: PropertySQLExpression, C6: PropertySQLExpression, C7: PropertySQLExpression, C8: PropertySQLExpression, C9: PropertySQLExpression, C10: PropertySQLExpression, C11: PropertySQLExpression
    >(
        _ c0: C0, _ c1: C1, _ c2: C2, _ c3: C3, _ c4: C4, _ c5: C5, _ c6: C6, _ c7: C7, _ c8: C8, _ c9: C9, _ c10: C10, _ c11: C11
    ) -> Result<Intersection12<C0.Property, C1.Property, C2.Property, C3.Property, C4.Property, C5.Property, C6.Property, C7.Property, C8.Property, C9.Property, C10.Property, C11.Property>> {
        Result(
            columns: [PropertySQLExpressionAsSQLExpression(c0), PropertySQLExpressionAsSQLExpression(c1), PropertySQLExpressionAsSQLExpression(c2), PropertySQLExpressionAsSQLExpression(c3), PropertySQLExpressionAsSQLExpression(c4), PropertySQLExpressionAsSQLExpression(c5), PropertySQLExpressionAsSQLExpression(c6), PropertySQLExpressionAsSQLExpression(c7), PropertySQLExpressionAsSQLExpression(c8), PropertySQLExpressionAsSQLExpression(c9), PropertySQLExpressionAsSQLExpression(c10), PropertySQLExpressionAsSQLExpression(c11)]
        )
    }
}

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

fileprivate struct GroupExpression<Property>: PropertySQLExpression {
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
