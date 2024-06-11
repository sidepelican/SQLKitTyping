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

    public static func buildBlock<C0: PropertySQLExpression>(_ component: C0) -> C0 {
        component
    }

//    public static func buildPartialBlock<T: PropertySQLExpression>(first: T) -> Result<T.Property> {
//        Result(
//            columns: [PropertySQLExpressionAsSQLExpression(first)]
//        )
//    }
//
//    public static func buildPartialBlock<each Accumulated, Next: PropertySQLExpression>(
//        accumulated: Result<repeat each Accumulated>,
//        next: Next
//    ) -> Result<repeat each Accumulated, Next.Property>
//    {
//        Result(
//            columns: accumulated.columns + CollectionOfOne(PropertySQLExpressionAsSQLExpression(next) as any SQLExpression)
//        )
//    }

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
