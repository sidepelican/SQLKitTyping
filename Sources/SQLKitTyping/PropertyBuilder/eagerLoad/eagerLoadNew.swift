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
    public func eagerLoadMany<
        Ref: HasManyReference
    >(
        sql: any SQLDatabase,
        for idKeyPath: KeyPath<Element, Ref.Column.Value>,
        reference: Ref,
        userInfo: [CodingUserInfoKey: any Sendable] = [:],
        buildOrderBy: (any SQLPartialResultBuilder) -> () = { _ in }
    )  async throws -> [Intersection2<Element, Ref.Property>] {
        return try await eagerLoadMany(
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

    public func eagerLoadMany<
        ID: Hashable, Many, ManyPropertyType
    >(
        idKey: KeyPath<Element, ID>,
        fetch: ([ID]) async throws -> [Many],
        mappingKey: KeyPath<Many, ID>,
        propertyInit: ([Many]) -> ManyPropertyType
    )  async throws -> [Intersection2<Element, ManyPropertyType>] {
        let ids = self.map { $0[keyPath: idKey] }

        let allChildren = try await fetch(ids)
        let childrenMap = Dictionary(grouping: allChildren, by: { $0[keyPath: mappingKey] })

        return self.map { row in
            let rowID = row[keyPath: idKey]
            let children = childrenMap[rowID] ?? []
            return .init((row, propertyInit(children)))
        }
    }
}

extension Optional {
    public func eagerLoadMany<
        Ref: HasManyReference
    >(
        sql: any SQLDatabase,
        for idKeyPath: KeyPath<Wrapped, Ref.Column.Value>,
        reference: Ref,
        userInfo: [CodingUserInfoKey: any Sendable] = [:],
        buildOrderBy: (any SQLPartialResultBuilder) -> () = { _ in }
    )  async throws -> Intersection2<Wrapped, Ref.Property>? {
        return try await eagerLoadMany(
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

    public func eagerLoadMany<
        ID: Equatable, Many, ManyPropertyType
    >(
        idKey: KeyPath<Wrapped, ID>,
        fetch: (ID) async throws -> [Many],
        propertyInit: ([Many]) -> ManyPropertyType
    )  async throws -> Intersection2<Wrapped, ManyPropertyType>? {
        guard let self else {
            return nil
        }
        let id = self[keyPath: idKey]
        let children = try await fetch(id)
        return .init((self, propertyInit(children)))
    }
}

extension Array {
    public func eagerLoadOne<
        Ref: HasOneReference
    >(
        sql: any SQLDatabase,
        mappedBy idKeyPath: KeyPath<Element, Ref.Model.ID>,
        reference: Ref,
        userInfo: [CodingUserInfoKey: any Sendable] = [:],
        buildOrderBy: (any SQLPartialResultBuilder) -> () = { _ in }
    )  async throws -> [Intersection2<Element, Ref.Property>] {
        return try await eagerLoadOne(
            idKey: idKeyPath,
            fetch: { ids in
                let query = sql.select()
                    .column(Ref.Model.id, as: "__id")
                    .columns(SQLLiteral.all)
                    .from(Ref.Model.self)
                    .where(Ref.Model.id, .in, SQLBind.group(ids))
                buildOrderBy(query)
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

    public func eagerLoadOne<
        Ref: HasOneReference
    >(
        sql: any SQLDatabase,
        mappedBy idKeyPath: KeyPath<Element, Ref.Model.ID?>,
        reference: Ref,
        userInfo: [CodingUserInfoKey: any Sendable] = [:],
        buildOrderBy: (any SQLPartialResultBuilder) -> () = { _ in }
    )  async throws -> [Intersection2<Element, NullableProperty<Ref.Property>>] {
        return try await eagerLoadOne(
            idKey: idKeyPath,
            fetch: { ids in
                let query = sql.select()
                    .column(Ref.Model.id, as: "__id")
                    .columns(SQLLiteral.all)
                    .from(Ref.Model.self)
                    .where(Ref.Model.id, .in, SQLBind.group(ids))
                buildOrderBy(query)
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

    public func eagerLoadOne<
        ID: Hashable, One, OnePropertyType
    >(
        idKey: KeyPath<Element, ID>,
        fetch: ([ID]) async throws -> [One],
        mappingKey: KeyPath<One, ID>,
        propertyInit: (One) -> OnePropertyType
    )  async throws -> [Intersection2<Element, OnePropertyType>] {
        let ids = self.map { $0[keyPath: idKey] }

        let ones = try await fetch(ids)
        var onesMap: [ID: One] = [:]
        onesMap.reserveCapacity(ones.count)
        for one in ones {
            onesMap[one[keyPath: mappingKey]] = one
        }

        return try self.map { row in
            let rowID = row[keyPath: idKey]
            guard let one = onesMap[rowID] else {
                throw EagerLoadError.valueNotFound(id: "\(rowID)")
            }
            return .init((row, propertyInit(one)))
        }
    }

    public func eagerLoadOne<
        ID: Hashable, One, OnePropertyType
    >(
        idKey: KeyPath<Element, ID?>,
        fetch: ([ID]) async throws -> [One],
        mappingKey: KeyPath<One, ID>,
        propertyInit: (One) -> OnePropertyType
    )  async throws -> [Intersection2<Element, NullableProperty<OnePropertyType>>] {
        let ids = self.compactMap { $0[keyPath: idKey] }

        let ones = try await fetch(ids)
        var onesMap: [ID: One] = [:]
        onesMap.reserveCapacity(ones.count)
        for one in ones {
            onesMap[one[keyPath: mappingKey]] = one
        }

        return try self.map { row in
            guard let rowID = row[keyPath: idKey] else {
                return .init((row, NullableProperty(nil)))
            }
            guard let one = onesMap[rowID] else {
                throw EagerLoadError.valueNotFound(id: "\(rowID)")
            }
            return .init((row, NullableProperty(propertyInit(one))))
        }
    }
}

public enum EagerLoadError: Error {
    case valueNotFound(id: String)
}
