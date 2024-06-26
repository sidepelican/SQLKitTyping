import SQLKit

extension Array {
    public func eagerLoadMany<
        Ref: HasManyReference
    >(
        sql: any SQLDatabase,
        for idKeyPath: KeyPath<Element, Ref.Column.Value>,
        with reference: Ref.Type,
        userInfo: [CodingUserInfoKey: any Sendable] = [:],
        buildOrderBy: @escaping (any SQLPartialResultBuilder) -> () = { _ in }
    )  async throws -> [Intersection2<Element, Ref.Property>] {
        return try await HasManyEagerLoader(reference: reference, idKeyPath: idKeyPath, buildOrderBy: buildOrderBy)
            .run(self, sql: sql, userInfo: userInfo)
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
        with reference: Ref.Type,
        userInfo: [CodingUserInfoKey: any Sendable] = [:],
        buildOrderBy: @escaping (any SQLPartialResultBuilder) -> () = { _ in }
    )  async throws -> Intersection2<Wrapped, Ref.Property>? {
        guard let self else {
            return nil
        }
        return try await HasManyEagerLoader(reference: reference, idKeyPath: idKeyPath, buildOrderBy: buildOrderBy)
            .run([self], sql: sql, userInfo: userInfo)
            .first
    }
}

extension Array {
    public func eagerLoadOne<
        Ref: HasOneReference
    >(
        sql: any SQLDatabase,
        mappedBy idKeyPath: KeyPath<Element, Ref.Model.ID>,
        with reference: Ref.Type,
        userInfo: [CodingUserInfoKey: any Sendable] = [:]
    )  async throws -> [Intersection2<Element, Ref.Property>] {
        return try await HasOneEagerLoader(reference: reference, idKeyPath: idKeyPath)
            .run(self, sql: sql, userInfo: userInfo)
    }

    public func eagerLoadOne<
        Ref: HasOneReference
    >(
        sql: any SQLDatabase,
        mappedBy idKeyPath: KeyPath<Element, Ref.Model.ID?>,
        with reference: Ref.Type,
        userInfo: [CodingUserInfoKey: any Sendable] = [:]
    )  async throws -> [Intersection2<Element, NullableProperty<Ref.Property>>] {
        return try await HasOneOptionalEagerLoader(reference: reference, idKeyPath: idKeyPath)
            .run(self, sql: sql, userInfo: userInfo)
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
