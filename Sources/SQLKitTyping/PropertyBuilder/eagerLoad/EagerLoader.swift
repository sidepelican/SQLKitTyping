import SQLKit

protocol EagerLoader {
    associatedtype Model
    associatedtype Property
    func run(_ models: [Model], sql: any SQLDatabase, userInfo: [CodingUserInfoKey: any Sendable]) async throws -> [Intersection2<Model, Property>]
}

struct HasManyEagerLoader<
    Ref: HasManyReference,
    From
>: EagerLoader {
    typealias Property = Ref.Property

    var reference: Ref.Type
    var idKeyPath: KeyPath<From, Ref.Column.Value>
    var buildOrderBy: (any SQLPartialResultBuilder) -> () = { _ in }

    func run(_ models: [From], sql: any SQLDatabase, userInfo: [CodingUserInfoKey: any Sendable]) async throws -> [Intersection2<From, Property>] {
        return try await models.eagerLoadMany(
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
}

struct HasOneEagerLoader<
    Ref: HasOneReference,
    From
>: EagerLoader {
    typealias Property = Ref.Property

    var reference: Ref.Type
    var idKeyPath: KeyPath<From, Ref.Model.ID>

    func run(_ models: [From], sql: any SQLDatabase, userInfo: [CodingUserInfoKey: any Sendable]) async throws -> [Intersection2<From, Property>] {
        return try await models.eagerLoadOne(
            idKey: idKeyPath,
            fetch: { ids in
                let query = sql.select()
                    .column(Ref.Model.id, as: "__id")
                    .columns(SQLLiteral.all)
                    .from(Ref.Model.self)
                    .where(Ref.Model.id, .in, SQLBind.group(ids))
                return try await query
                    .all(
                        decoding: RowWithInternalID<Ref.Model.ID, Ref.Model>.self,
                        userInfo: userInfo
                    )
            },
            mappingKey: \RowWithInternalID<Ref.Model.ID, Ref.Model>.__id,
            propertyInit: {
                reference.initProperty($0.row)
            }
        )
    }
}

struct HasOneOptionalEagerLoader<
    Ref: HasOneReference,
    From
>: EagerLoader {
    typealias Property = NullableProperty<Ref.Property>

    var reference: Ref.Type
    var idKeyPath: KeyPath<From, Ref.Model.ID?>

    func run(_ models: [From], sql: any SQLDatabase, userInfo: [CodingUserInfoKey: any Sendable]) async throws -> [Intersection2<From, Property>] {
        return try await models.eagerLoadOne(
            idKey: idKeyPath,
            fetch: { ids in
                let query = sql.select()
                    .column(Ref.Model.id, as: "__id")
                    .columns(SQLLiteral.all)
                    .from(Ref.Model.self)
                    .where(Ref.Model.id, .in, SQLBind.group(ids))
                return try await query
                    .all(
                        decoding: RowWithInternalID<Ref.Model.ID, Ref.Model>.self,
                        userInfo: userInfo
                    )
            },
            mappingKey: \RowWithInternalID<Ref.Model.ID, Ref.Model>.__id,
            propertyInit: {
                reference.initProperty($0.row)
            }
        )
    }
}

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
