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
        Ref: HasManyReference
    >(
        sql: any SQLDatabase,
        for idKeyPath: KeyPath<Element, Ref.Column.Value>,
        reference: Ref,
        userInfo: [CodingUserInfoKey: any Sendable] = [:],
        buildOrderBy: (any SQLPartialResultBuilder) -> () = { _ in }
    )  async throws -> [Intersection2<Element, Ref.Property>] {
        return try await eagerLoad(
            idKey: idKeyPath,
            fetch: { ids in
                let query = sql.select()
                    .column(reference.column, as: "__id")
                    .columns(SQLLiteral.all)
                    .from(Ref.Column.Schema.self)
                    .where(reference.column, .in, SQLBind.group(ids))
                buildOrderBy(query)
                return try await query
                    .all(
                        decoding: RowWithInternalID<Ref.Column.Value, Ref.Model>.self,
                        userInfo: userInfo
                    )
            },
            mappingKey: \RowWithInternalID<Ref.Column.Value, Ref.Model>.__id,
            propertyInit: {
                reference.initProperty($0.map(\.row))
            }
        )
    }

    public func eagerLoad<
        ID: Hashable, Many, ManyPropertyType
    >(
        idKey idKeyPath: KeyPath<Element, ID>,
        fetch: ([ID]) async throws -> [Many],
        mappingKey: KeyPath<Many, ID>,
        propertyInit: ([Many]) -> ManyPropertyType
    )  async throws -> [Intersection2<Element, ManyPropertyType>] {
        let ids = self.map { $0[keyPath: idKeyPath] }

        let allChildren = try await fetch(ids)
        let childrenMap = Dictionary(grouping: allChildren, by: { $0[keyPath: mappingKey] })

        return self.map { row in
            let rowID = row[keyPath: idKeyPath]
            let children = childrenMap[rowID] ?? []
            return .init((row, propertyInit(children)))
        }
    }
}

extension Optional {
    public func eagerLoad<
        Ref: HasManyReference
    >(
        sql: any SQLDatabase,
        for idKeyPath: KeyPath<Wrapped, Ref.Column.Value>,
        reference: Ref,
        userInfo: [CodingUserInfoKey: any Sendable] = [:],
        buildOrderBy: (any SQLPartialResultBuilder) -> () = { _ in }
    )  async throws -> Intersection2<Wrapped, Ref.Property>? {
        return try await eagerLoadChildren(
            idKey: idKeyPath,
            fetch: { id in
                let query = sql.select()
                    .columns(SQLLiteral.all)
                    .from(Ref.Column.Schema.self)
                    .where(reference.column, .equal, id)
                buildOrderBy(query)
                return try await query
                    .all(
                        decoding: Ref.Model.self,
                        userInfo: userInfo
                    )
            },
            propertyInit: {
                reference.initProperty($0)
            }
        )
    }

    public func eagerLoadChildren<
        ID: Equatable, Many, ManyPropertyType
    >(
        idKey idKeyPath: KeyPath<Wrapped, ID>,
        fetch: (ID) async throws -> [Many],
        propertyInit: ([Many]) -> ManyPropertyType
    )  async throws -> Intersection2<Wrapped, ManyPropertyType>? {
        guard let self else {
            return nil
        }
        let id = self[keyPath: idKeyPath]
        let children = try await fetch(id)
        return .init((self, propertyInit(children)))
    }
}

//extension Array {
//    public func eagerLoad<
//        Ref: HasOneReference
//    >(
//        sql: any SQLDatabase,
//        for idKeyPath: KeyPath<Element, Ref.Column.Value>,
//        _ ref: () -> Ref,
//        userInfo: [CodingUserInfoKey: any Sendable] = [:],
//        @PropertyBuilder buildColumns: () -> PropertyBuilder.Result<Ref.Model>,
//        buildOrderBy: (any SQLPartialResultBuilder) -> () = { _ in }
//    )  async throws -> [Intersection2<Element, Ref.Property>] {
////        let ref = ref()
////        let ids = self.map { $0[keyPath: idKeyPath] }
////
////        let query = sql.select()
////            .column(Ref.Model, as: "__id")
////            .columns(buildColumns().columns)
////            .from(Ref.Column.Schema.self)
////            .where(ref.column, .in, SQLBind.group(ids))
////        buildOrderBy(query)
////        let allChildren = try await query
////            .all(
////                decoding: RowWithInternalID<Ref.Column.Value, Ref.Model>.self,
////                userInfo: userInfo
////            )
////
////        return addParent(
////            array: self,
////            elementIDKeyPath: idKeyPath,
////            allChildren: allChildren,
////            initProperty: ref.initProperty
////        )
//    }
//
//    public func eagerLoadParent<
//        ID: Hashable, Parent, ParentPropertyType
//    >(
//        parentKey idKeyPath: KeyPath<Element, ID>,
//        fetch: ([ID]) async throws -> [Parent],
//        parentIDKey parentKeyPath: KeyPath<Parent, ID>,
//        parentPropertyInit: (Parent) -> ParentPropertyType
//    )  async throws -> [Intersection2<Element, ParentPropertyType>] {
//        let ids = self.map { $0[keyPath: idKeyPath] }
//
//        let allParents = try await fetch(ids)
//        var parentMap: [ID: Parent] = [:]
//        parentMap.reserveCapacity(allParents.count)
//        for parent in allParents {
//            parentMap[parent[keyPath: parentKeyPath]] = parent
//        }
//
//        return self.map { row in
//            let rowID = row[keyPath: idKeyPath]
//            let parent = parentMap[rowID]
//            return .init((row, parentPropertyInit(parent)))
//        }
//    }
//
//}
