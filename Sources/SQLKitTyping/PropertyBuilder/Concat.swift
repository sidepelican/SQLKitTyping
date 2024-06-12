import SQLKit

//@dynamicMemberLookup
//public struct PropertyConcat<L: Decodable, R: Decodable>: Decodable {
//    public init(left: L, right: R) {
//        self.left = left
//        self.right = right
//    }
//
//    @usableFromInline var left: L
//    @usableFromInline var right: R
//
//    @inlinable
//    public subscript<T>(dynamicMember keyPath: KeyPath<L, T>) -> T {
//        left[keyPath: keyPath]
//    }
//
//    @inlinable
//    public subscript<T>(dynamicMember keyPath: KeyPath<R, T>) -> T {
//        right[keyPath: keyPath]
//    }
//
//    public init(from decoder: any Decoder) throws {
//        let container = try decoder.singleValueContainer()
//        self.left = try container.decode(L.self)
//        self.right = try container.decode(R.self)
//    }
//}

//@dynamicMemberLookup
//public struct _Concatenated<each V: Decodable>: Decodable {
//    public init(_ value: repeat each V) {
//        self.value = (repeat each value)
//    }
//    @usableFromInline var value: (repeat each V)
//
//    @inlinable
//    public subscript<T>(dynamicMember keyPath: KeyPath<(repeat each V), T>) -> T {
//        value[keyPath: keyPath]
//    }
//
//    public init(from decoder: any Decoder) throws {
//        let container = try decoder.singleValueContainer()
//        self.value = try (repeat container.decode((each V).self))
//    }
//}

public struct PropertyNullableColumn<Base: PropertySQLExpression>: PropertySQLExpression where Base.Property: Decodable {
    @inlinable
    public init(base: Base) {
        self.base = base
    }

    @dynamicMemberLookup
    public struct Property: Decodable {
        public var wrapped: Base.Property?

        public init(from decoder: any Decoder) throws {
            let container = try decoder.singleValueContainer()
            do {
                wrapped = try container.decode(Base.Property.self)
            } catch let error as DecodingError {
                if case .valueNotFound = error {
                    wrapped = nil
                }
            }
        }

        @inlinable
        public subscript<T>(dynamicMember keyPath: KeyPath<Base.Property, T>) -> T? {
            wrapped?[keyPath: keyPath]
        }
    }

    @usableFromInline
    var base: Base

    public func serializeAsPropertySQLExpression(to serializer: inout SQLSerializer)  {
        base.serializeAsPropertySQLExpression(to: &serializer)
    }
}

extension PropertySQLExpression where Self.Property: Decodable {
    @inlinable
    public var nullable: PropertyNullableColumn<Self> {
        PropertyNullableColumn(base: self)
    }
}

public protocol PropertySQLExpression<Property>: Sendable {
    associatedtype Property
    func serializeAsPropertySQLExpression(to serializer: inout SQLSerializer)
}

public struct PropertySQLExpressionAsSQLExpression<Base: PropertySQLExpression>: SQLExpression {
    @inlinable
    public init(_ base: Base) {
        self.base = base
    }
    public var base: Base

    @inlinable
    public func serialize(to serializer: inout SQLSerializer) {
        base.serializeAsPropertySQLExpression(to: &serializer)
    }
}

public protocol SQLTypedQueryFetcher<Row>: SQLQueryFetcher {
    associatedtype Row: Decodable
}

extension SQLTypedQueryFetcher {
    public func first(
        prefix: String? = nil,
        keyDecodingStrategy: SQLRowDecoder.KeyDecodingStrategy = .useDefaultKeys,
        userInfo: [CodingUserInfoKey: any Sendable] = [:]
    ) async throws -> Row? {
        guard let row = try await first() as (any SQLRow)? else {
            return nil
        }
        let decoder = SQLRowDecoder(prefix: prefix, keyDecodingStrategy: keyDecodingStrategy, userInfo: userInfo)
        return try row.decode(model: Row.self, with: decoder)
    }

    public func all(
        prefix: String? = nil,
        keyDecodingStrategy: SQLRowDecoder.KeyDecodingStrategy = .useDefaultKeys,
        userInfo: [CodingUserInfoKey: any Sendable] = [:]
    ) async throws -> [Row] {
        let rows = try await all() as [any SQLRow]
        let decoder = SQLRowDecoder(prefix: prefix, keyDecodingStrategy: keyDecodingStrategy, userInfo: userInfo)
        return try rows.map { try $0.decode(model: Row.self, with: decoder) }
    }
}

public final class SQLTypedSelectBuilder<Row: Decodable>: SQLQueryBuilder, SQLTypedQueryFetcher, SQLSubqueryClauseBuilder {
    public var select: SQLSelect

    public var database: any SQLDatabase

    @inlinable
    public var query: any SQLExpression {
        self.select
    }

    @inlinable
    public init(on database: any SQLDatabase) {
        self.select = .init()
        self.database = database
    }
}

extension SQLDatabase {
    @available(*, unavailable, message: ".withTable cannot use here")
    public func selectWithColumn(_ column: SQLAllColumn) -> SQLSelectBuilder {
        fatalError()
    }

    @inlinable
    public func selectWithColumn<Expr: PropertySQLExpression>(_ column: Expr) -> SQLTypedSelectBuilder<Expr.Property> {
        let builder = SQLTypedSelectBuilder<Expr.Property>(on: self)
        builder.column(PropertySQLExpressionAsSQLExpression(column))
        return builder
    }

    @inlinable
    public func selectWithColumns<T>(@PropertyBuilder _ build: () -> PropertyBuilder.Result<T>) -> SQLTypedSelectBuilder<T> {
        let builder = SQLTypedSelectBuilder<T>(on: self)
        builder.columns(build().columns)
        return builder
    }
}

public final class SQLTypedReturningResultBuilder<Row: Decodable>: SQLTypedQueryFetcher {
    public var query: any SQLExpression
    public var database: any SQLDatabase
    @usableFromInline
    init(_ builder: some SQLReturningBuilder) {
        self.query = builder.query
        self.database = builder.database
    }
}

extension SQLReturningBuilder {
    @inlinable
    public func returning<Expr: PropertySQLExpression>(_ column: Expr) -> SQLTypedReturningResultBuilder<Expr.Property> {
        self.returning = .init([PropertySQLExpressionAsSQLExpression(column)])
        return SQLTypedReturningResultBuilder(self)
    }

    @inlinable
    public func returningWithColumns<T>(@PropertyBuilder _ build: () -> PropertyBuilder.Result<T>) -> SQLTypedReturningResultBuilder<T> {
        self.returning = .init(build().columns)
        return SQLTypedReturningResultBuilder(self)
    }
}

func playground(db: any SQLDatabase) async throws {
//    #SQLPartialDecodeType(name: "Email", type: String.self)
//    print(Email.self)

    let row = try await db.selectWithColumns {
        UserTable.all
        group {
            UserTable.familyName
            UserTable.familyNameKana
        }
    }
    .from(UserTable.self)
    .join("emails", on: UserTable.id.withTable, .equal, SQLColumn("userID", table: "emails"))
    .where(UserTable.id, .equal, 123)
    .first()!
//    UserTable.fami
    let row2 = try await db.insert(into: UserTable.self)
        .returning(UserTable.tel)
        .first()?.tel

    print(row.familyName)
    print(row.1.group.familyNameKana ?? "null")
//    print(row.email)
}

@Schema
package struct UserTable: SchemaProtocol {
    package static var tableName: String { "users" }

    package var id: Int
    package var familyName: String
    package var givenName: String
    package var familyNameKana: String?
    package var givenNameKana: String?
    package var tel: String
}
