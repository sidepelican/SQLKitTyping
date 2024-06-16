import SQLKit

public protocol SQLTypedQueryFetcher<Row>: SQLQueryFetcher {
    associatedtype Row: Decodable
}

extension SQLTypedQueryFetcher {
    public func first(
        userInfo: [CodingUserInfoKey: any Sendable] = [:]
    ) async throws -> Row? {
        guard let row = try await first() as (any SQLRow)? else {
            return nil
        }
        let decoder = SQLRowDecoder(prefix: nil, keyDecodingStrategy: .useDefaultKeys, userInfo: userInfo)
        return try row.decode(model: Row.self, with: decoder)
    }

    public func firstWithRow(
        userInfo: [CodingUserInfoKey: any Sendable] = [:]
    ) async throws -> (Row, any SQLRow)? {
        guard let row = try await first() as (any SQLRow)? else {
            return nil
        }
        let decoder = SQLRowDecoder(prefix: nil, keyDecodingStrategy: .useDefaultKeys, userInfo: userInfo)
        return (try row.decode(model: Row.self, with: decoder), row)
    }

    public func all(
        userInfo: [CodingUserInfoKey: any Sendable] = [:]
    ) async throws -> [Row] {
        let rows = try await all() as [any SQLRow]
        let decoder = SQLRowDecoder(prefix: nil, keyDecodingStrategy: .useDefaultKeys, userInfo: userInfo)
        return try rows.map { try $0.decode(model: Row.self, with: decoder) }
    }

    public func allWithRow(
        userInfo: [CodingUserInfoKey: any Sendable] = [:]
    ) async throws -> [(Row, any SQLRow)] {
        let rows = try await all() as [any SQLRow]
        let decoder = SQLRowDecoder(prefix: nil, keyDecodingStrategy: .useDefaultKeys, userInfo: userInfo)
        return try rows.map { (try $0.decode(model: Row.self, with: decoder), $0) }
    }
}
