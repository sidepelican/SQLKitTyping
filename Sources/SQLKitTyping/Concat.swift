import SQLKit

@dynamicMemberLookup
public struct Concat<L: Decodable, R: Decodable>: Decodable {
    public init(left: L, right: R) {
        self.left = left
        self.right = right
    }
    private var left: L
    private var right: R

    public subscript<T>(dynamicMember keyPath: KeyPath<L, T>) -> T {
        left[keyPath: keyPath]
    }

    public subscript<T>(dynamicMember keyPath: KeyPath<R, T>) -> T {
        right[keyPath: keyPath]
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.left = try container.decode(L.self)
        self.right = try container.decode(R.self)
    }
}

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

public struct TypedColumns<PropertyType: Decodable> {
    public var columns: [any SQLExpression]
}

@resultBuilder
public struct RowBuilder {
    public static func buildBlock<T>(_ component: T) -> T {
        component
    }

    public static func buildPartialBlock<T: PropertySQLExpression>(first: T) -> TypedColumns<T.Property> {
        TypedColumns(
            columns: [PropertySQLExpressionAsSQLExpression(base: first)]
        )
    }

    public static func buildPartialBlock<Accumulated, Next: PropertySQLExpression>(
        accumulated: TypedColumns<Accumulated>,
        next: Next
    ) -> TypedColumns<Concat<Accumulated, Next.Property>>
    {
        TypedColumns(
            columns: accumulated.columns + CollectionOfOne(PropertySQLExpressionAsSQLExpression(base: next) as any SQLExpression)
        )
    }
}

public final class SQLTypedSelectBuilder<Row: Decodable>: SQLQueryBuilder, SQLQueryFetcher, SQLSubqueryClauseBuilder {
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

struct PropertySQLExpressionAsSQLExpression<Base: PropertySQLExpression>: SQLExpression {
    var base: Base
    func serialize(to serializer: inout SQLSerializer) {
        base.serializeAsPropertySQLExpression(to: &serializer)
    }
}

extension SQLDatabase {
    public func selectWithColumns<Row>(@RowBuilder build: () -> TypedColumns<Row>) -> SQLTypedSelectBuilder<Row> {
        let builder = SQLTypedSelectBuilder<Row>(on: self)
        builder.columns(build().columns)
        return builder
    }
}

//@freestanding(declaration)
//macro SQLPartialDecodeType(_ dic: [String: any Decodable.Type], name: String? = nil)

func playground(db: any SQLDatabase) async throws {
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
//
//        func serializeAsPropertySQLExpression(to serializer: inout SQLSerializer)  {
//            SQLAlias(expr, as: "email").serialize(to: &serializer)
//        }
//    }
//    // マクロで展開ここまで

    let row = try await db.selectWithColumns {
        UserTable.familyName
        UserTable.givenName.nullable
//        email(SQLColumn("email", table: "emails"))
    }
    .from(UserTable.tableName)
    .join("emails", on: UserTable.id.withTable, .equal, SQLColumn("userID", table: "emails"))
    .where(UserTable.id, .equal, 123)
    .first()!

    print(row.familyName)
    print(row.givenName ?? "null")
//    print(row.email)
}

@Schema
public struct UserTable: SchemaProtocol {
    public static var tableName: String { "users" }

    public var id: Int
    public var familyName: String
    public var givenName: String
    public var familyNameKana: String
    public var givenNameKana: String
    public var tel: String
}
