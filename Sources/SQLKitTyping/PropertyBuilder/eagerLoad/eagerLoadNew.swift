import SQLKit

struct RowWithInternalID<ID: Decodable, Row: Decodable>: Decodable {
    var __id: ID
    var row: Row
    enum CodingKeys: String, CodingKey {
        case __id
    }
    init(from decoder: any Decoder) throws {
        __id = try decoder.container(keyedBy: CodingKeys.self).decode(ID.self, forKey: .__id)
        row = try decoder.singleValueContainer().decode(Row.self)
    }
}

extension Array {
    public func eagerLoad<
        Ref: ChildrenReference
    >(
        sql: any SQLDatabase,
        for idKeyPath: KeyPath<Element, Ref.Column.Value>,
        children ref: Ref,
        userInfo: [CodingUserInfoKey: any Sendable] = [:],
        buildOrderBy: (any SQLPartialResultBuilder) -> () = { _ in }
    )  async throws -> [Intersection2<Element, Ref.Property>] {
        return try await eagerLoadChildren(
            idKey: idKeyPath,
            fetch: { ids in
                let query = sql.select()
                    .column(ref.column, as: "__id")
                    .columns(SQLLiteral.all)
                    .from(Ref.Column.Schema.self)
                    .where(ref.column, .in, SQLBind.group(ids))
                buildOrderBy(query)
                return try await query
                    .all(
                        decoding: RowWithInternalID<Ref.Column.Value, Ref.Child>.self,
                        userInfo: userInfo
                    )
            },
            parentKey: \RowWithInternalID<Ref.Column.Value, Ref.Child>.__id,
            childrenPropertyInit: {
                ref.initProperty($0.map(\.row))
            }
        )
    }

    public func eagerLoadChildren<
        ID: Equatable, Child, ChildrenPropertyType
    >(
        idKey idKeyPath: KeyPath<Element, ID>,
        fetch: ([ID]) async throws -> [Child],
        parentKey parentKeyPath: KeyPath<Child, ID>,
        childrenPropertyInit: ([Child]) -> ChildrenPropertyType
    )  async throws -> [Intersection2<Element, ChildrenPropertyType>] {
        let ids = self.map { $0[keyPath: idKeyPath] }

        let allChildren = try await fetch(ids)

        return self.map { row in
            let rowID = row[keyPath: idKeyPath]
            let children = allChildren.filter { $0[keyPath: parentKeyPath] == rowID }
            return .init((row, childrenPropertyInit(children)))
        }
    }
}

fileprivate func addChildren<Element, Child, Property, ID: Equatable>(
    array: [Element],
    elementIDKeyPath: KeyPath<Element, ID>,
    allChildren: [RowWithInternalID<ID, Child>],
    initProperty: ([Child]) -> Property
) -> [Intersection2<Element, Property>] {
    return array.map { row in
        let rowID = row[keyPath: elementIDKeyPath]
        let children = allChildren.filter { $0.__id == rowID }.map(\.row)
        let childrenProperty = initProperty(children)
        return .init((row, childrenProperty))
    }
}

extension Optional {
    public func eagerLoad<
        Ref: ChildrenReference
    >(
        sql: any SQLDatabase,
        for idKeyPath: KeyPath<Wrapped, Ref.Column.Value>,
        children ref: Ref,
        userInfo: [CodingUserInfoKey: any Sendable] = [:],
        buildOrderBy: (any SQLPartialResultBuilder) -> () = { _ in }
    )  async throws -> Intersection2<Wrapped, Ref.Property>? {
        return try await eagerLoadChildren(
            idKey: idKeyPath,
            fetch: { id in
                let query = sql.select()
                    .columns(SQLLiteral.all)
                    .from(Ref.Column.Schema.self)
                    .where(ref.column, .equal, id)
                buildOrderBy(query)
                return try await query
                    .all(
                        decoding: Ref.Child.self,
                        userInfo: userInfo
                    )
            },
            childrenPropertyInit: {
                ref.initProperty($0)
            }
        )
    }

    public func eagerLoadChildren<
        ID: Equatable, Child, ChildrenPropertyType
    >(
        idKey idKeyPath: KeyPath<Wrapped, ID>,
        fetch: (ID) async throws -> [Child],
        childrenPropertyInit: ([Child]) -> ChildrenPropertyType
    )  async throws -> Intersection2<Wrapped, ChildrenPropertyType>? {
        guard let self else {
            return nil
        }
        let id = self[keyPath: idKeyPath]
        let children = try await fetch(id)
        return .init((self, childrenPropertyInit(children)))
    }
}

//extension Array {
//    public func eagerLoad<
//        Ref: ParentReference
//    >(
//        sql: any SQLDatabase,
//        for idKeyPath: KeyPath<Element, Ref.Column.Value>,
//        _ ref: () -> Ref,
//        userInfo: [CodingUserInfoKey: any Sendable] = [:],
//        @PropertyBuilder buildColumns: () -> PropertyBuilder.Result<Ref.Parent>,
//        buildOrderBy: (any SQLPartialResultBuilder) -> () = { _ in }
//    )  async throws -> [Intersection2<Element, Ref.Property>] {
//        let ref = ref()
//        let ids = self.map { $0[keyPath: idKeyPath] }
//
//        let query = sql.select()
//            .column(Ref.Parent, as: "__id")
//            .columns(buildColumns().columns)
//            .from(Ref.Column.Schema.self)
//            .where(ref.column, .in, SQLBind.group(ids))
//        buildOrderBy(query)
//        let allChildren = try await query
//            .all(
//                decoding: RowWithInternalID<Ref.Column.Value, Ref.Parent>.self,
//                userInfo: userInfo
//            )
//
//        return addParent(
//            array: self,
//            elementIDKeyPath: idKeyPath,
//            allChildren: allChildren,
//            initProperty: ref.initProperty
//        )
//    }
//}
//
//fileprivate func addParent<Element, Parent, Property, ID: Equatable>(
//    array: [Element],
//    elementIDKeyPath: KeyPath<Element, ID>,
//    allChildren: [RowWithInternalID<ID, Parent>],
//    initProperty: (Parent) -> Property
//) -> [Intersection2<Element, Property>] {
//    return array.map { row in
//        let rowID = row[keyPath: elementIDKeyPath]
//        let children = allChildren.filter { $0.__id == rowID }.map(\.row)
//        let childrenProperty = initProperty(children)
//        return .init((row, childrenProperty))
//    }
//}
//
//
