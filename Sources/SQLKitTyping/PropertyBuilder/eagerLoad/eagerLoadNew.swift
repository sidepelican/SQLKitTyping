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
        _ ref: () -> Ref,
        userInfo: [CodingUserInfoKey: any Sendable] = [:],
        @PropertyBuilder buildColumns: () -> PropertyBuilder.Result<Ref.Child>
    )  async throws -> [Intersection2<Element, Ref.Property>] {
        let ref = ref()
        let ids = self.map { $0[keyPath: idKeyPath] }

        let allChildren = try await sql.select()
            .column(ref.column, as: "__id")
            .columns(buildColumns().columns)
            .from(Ref.Column.Schema.self)
            .where(ref.column, .in, SQLBind.group(ids))
            .all(
                decoding: RowWithInternalID<Ref.Column.Value, Ref.Child>.self,
                userInfo: userInfo
            )

        return self.map { row in
            let children = allChildren.filter { $0.__id == row[keyPath: idKeyPath] }.map(\.row)
            let childrenProperty = ref.initProperty(children)
            return .init((row, childrenProperty))
        }
    }
}

extension Optional {
    public func eagerLoad<
        Ref: ChildrenReference
    >(
        sql: any SQLDatabase,
        for idKeyPath: KeyPath<Wrapped, Ref.Column.Value>,
        _ ref: () -> Ref,
        userInfo: [CodingUserInfoKey: any Sendable] = [:],
        @PropertyBuilder buildColumns: () -> PropertyBuilder.Result<Ref.Child>
    )  async throws -> Intersection2<Wrapped, Ref.Property>? {
        guard let self else {
            return nil
        }
        let ref = ref()
        let id = self[keyPath: idKeyPath]

        let children = try await sql.select()
            .columns(buildColumns().columns)
            .from(Ref.Column.Schema.self)
            .where(ref.column, .equal, id)
            .all(
                decoding: Ref.Child.self,
                userInfo: userInfo
            )

        return .init((self, ref.initProperty(children)))
    }
}
