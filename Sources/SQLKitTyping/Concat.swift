//import SQLKit
//
//@dynamicMemberLookup
//public struct Concat<L: Decodable, R: Decodable>: Decodable {
//    public init(left: L, right: R) {
//        self.left = left
//        self.right = right
//    }
//    private var left: L
//    private var right: R
//
//    public subscript<T>(dynamicMember keyPath: KeyPath<L, T>) -> T {
//        left[keyPath: keyPath]
//    }
//
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
//
//public protocol SinglePropertyType {
//    associatedtype ValueType
//}
//
//public protocol PropertySQLExpression<Property>: SQLExpression {
//    associatedtype Property
//}
//
//public struct TypedColumns<PropertyType: Decodable> {
//    public var columns: [any SQLExpression]
//}
//
//@resultBuilder
//public struct RowBuilder {
//    public static func buildBlock<T>(_ component: T) -> T {
//        component
//    }
//
//    public static func buildPartialBlock<T: PropertySQLExpression>(first: T) -> TypedColumns<T.Property> {
//        TypedColumns(
//            columns: [first]
//        )
//    }
//
//    public static func buildPartialBlock<Accumulated, Next: PropertySQLExpression>(
//        accumulated: TypedColumns<Accumulated>,
//        next: Next
//    ) -> TypedColumns<Concat<Accumulated, Next.Property>>
//    {
//        TypedColumns(
//            columns: accumulated.columns + CollectionOfOne(next as any SQLExpression)
//        )
//    }
//}
//
//public final class SQLTypedSelectBuilder<Row: Decodable>: SQLQueryBuilder, SQLQueryFetcher, SQLSubqueryClauseBuilder {
//    public var select: SQLSelect
//
//    public var database: any SQLDatabase
//
//    @inlinable
//    public var query: any SQLExpression {
//        self.select
//    }
//
//    @inlinable
//    public init(on database: any SQLDatabase) {
//        self.select = .init()
//        self.database = database
//    }
//
//    public func first(
//        prefix: String? = nil,
//        keyDecodingStrategy: SQLRowDecoder.KeyDecodingStrategy = .useDefaultKeys,
//        userInfo: [CodingUserInfoKey: any Sendable] = [:]
//    ) async throws -> Row? {
//        guard let row = try await first() as (any SQLRow)? else {
//            return nil
//        }
//        let decoder = SQLRowDecoder(prefix: prefix, keyDecodingStrategy: keyDecodingStrategy, userInfo: userInfo)
//        return try row.decode(model: Row.self, with: decoder)
//    }
//
//    public func all(
//        prefix: String? = nil,
//        keyDecodingStrategy: SQLRowDecoder.KeyDecodingStrategy = .useDefaultKeys,
//        userInfo: [CodingUserInfoKey: any Sendable] = [:]
//    ) async throws -> [Row] {
//        let rows = try await all() as [any SQLRow]
//        let decoder = SQLRowDecoder(prefix: prefix, keyDecodingStrategy: keyDecodingStrategy, userInfo: userInfo)
//        return try rows.map { try $0.decode(model: Row.self, with: decoder) }
//    }
//}
//
//extension SQLDatabase {
//    /// Create a new ``SQLSelectBuilder``.
//    @inlinable
//    public func selectWithColumns<Row>(@RowBuilder build: () -> TypedColumns<Row>) -> SQLTypedSelectBuilder<Row> {
//        let builder = SQLTypedSelectBuilder<Row>(on: self)
//        builder.columns(build().columns)
//        return builder
//    }
//}
//
//@freestanding(declaration)
//macro SQLPartialDecodeType(_ dic: [String: any Decodable.Type], name: String? = nil)
//
//func playground(db: any SQLDatabase) async throws {
//    #SQLPartialDecodeType(["email": String.self])
//    // マクロで展開
//    struct email: PropertySQLExpression {
//        init(_ expr: any SQLExpression) {
//            self.expr = expr
//        }
//        var expr: any SQLExpression
//        struct Property: Decodable {
//            var email: String
//            enum CodingKeys: String, CodingKey {
//                case email = "email"
//            }
//        }
//        @inlinable
//        func serialize(to serializer: inout SQLSerializer) {
//            SQLAlias(expr, as: "email").serialize(to: &serializer)
//        }
//    }
//    // マクロで展開ここまで
//
//    let row = try await db.selectWithColumns {
//        UserTable.familyName2
//        UserTable.givenName2
//        email(SQLColumn("email", table: "emails"))
//    }
//    .from(UserTable.tableName)
//    .join("emails", on: UserTable.id.withTable, .equal, SQLColumn("userID", table: "emails"))
//    .where(UserTable.id, .equal, 123)
//    .first()!
//
//    print(row.familyName2)
//    print(row.givenName2)
//    print(row.email)
//}
//
//@Schema
//public struct UserTable: SchemaProtocol {
//    public static var tableName: String { "users" }
//
//    public var id: Int
//
//    public struct _FamilyName2: TypedSQLColumn, PropertySQLExpression {
//        public typealias Schema = UserTable
//        public typealias Value = Property.ValueType
//        public struct Property: Decodable, SinglePropertyType {
//            public typealias ValueType = String
//            public var familyName2: String
//            public enum CodingKeys: String, CodingKey {
//                case familyName2 = "users_familyName2"
//            }
//        }
//
//        public var name: String { "familyName2" }
//
//        @inlinable
//        public func serialize(to serializer: inout SQLSerializer) {
//            SQLAlias(SQLColumn("familyName2", table: UserTable.tableName), as: "users_familyName2")
//                .serialize(to: &serializer)
//        }
//    }
//    public static let familyName2 = _FamilyName2()
//
//    public struct _GivenName2: PropertySQLExpression {
//        public struct Property: Decodable, SinglePropertyType {
//            public typealias ValueType = String
//            public var givenName2: String
//        }
//        @inlinable
//        public func serialize(to serializer: inout SQLSerializer) {
//            SQLColumn("givenName2", table: UserTable.tableName).serialize(to: &serializer)
//        }
//    }
//    public static let givenName2 = _GivenName2()
//
//    public var familyName: String
//    public var givenName: String
//    public var familyNameKana: String
//    public var givenNameKana: String
//    public var tel: String
//}
