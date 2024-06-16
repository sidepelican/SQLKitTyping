import XCTest
import SQLKitTyping

macro Children() = #externalMacro(module: "", type: "")

struct RecipeID: Hashable, Codable, Sendable {}
struct IngredientID: Hashable, Codable, Sendable {}

@Schema
public enum RecipeTable: IDSchemaProtocol {
    public static var tableName: String { "recipes" }

    var id: RecipeID

    var title: String
    fileprivate var kcal: Int

//    @Children(for: IngredientTable.recipeID)
//    var ingredients: Never

    static let ingredients = ReferenceBuilder(column: IngredientTable.recipeID)
}

protocol ChildrenReference<Column, Property> {
    associatedtype Column: TypedSQLColumn where Column.Value: Equatable
    associatedtype Property: ChildrenProperty
    associatedtype Child: Decodable
    var columnList: [any SQLExpression] { get }
    var column: Column { get }
    var initProperty: ([Child]) -> Property { get }
}

protocol ChildrenProperty {
    
}

struct ReferenceBuilder<Column: TypedSQLColumn> {
    var column: Column
    struct Property<Child: Decodable>: ChildrenProperty, Decodable {
        var ingredients: [Child]
    }
    func columns<Row>(@PropertyBuilder build: () -> PropertyBuilder.Result<Row>) -> GenericRerefence<Column, Property<Row>, Row> {
        return .init(
            columnList: build().columns,
            column: column,
            initProperty: Property.init
        )
    }
}

struct GenericRerefence<Column: TypedSQLColumn, Property: ChildrenProperty & Decodable, Child: Decodable>: ChildrenReference where Column.Value: Equatable {
    var columnList: [any SQLExpression]
    var column: Column
    var initProperty: ([Child]) -> Property
}

@Schema
enum IngredientTable: SchemaProtocol {
    static var tableName: String { "ingredients" }

    var recipeID: RecipeID
    var order: Int
    var name: String
}

struct IDProperty<T: Decodable>: Decodable {
    var __id: T
}

extension Array {
    func eagerLoad<
        Ref: ChildrenReference
    >(
        sql: some SQLDatabase,
        for idKeyPath: KeyPath<Element, Ref.Column.Value>,
        userInfo: [CodingUserInfoKey: any Sendable] = [:],
        _ ref: Ref
    )  async throws -> [Intersection2<Element, Ref.Property>] {
        let ids = self.map { $0[keyPath: idKeyPath] }

        let allChildren = try await sql.select()
            .column(ref.column, as: "__id")
            .columns(ref.columnList)
            .from(Ref.Column.Schema.self)
            .where(ref.column, .in, SQLBind.group(ids))
            .all(
                decoding: Intersection2<IDProperty<Ref.Column.Value>, Ref.Child>.self,
                userInfo: userInfo
            )

        return self.map { row in
            let children = allChildren.filter { $0.__id == row[keyPath: idKeyPath] }.map(\.values.1)
            let childrenProperty = ref.initProperty(children)
            return .init((row, childrenProperty))
        }
    }
}

func f(sql: some SQLDatabase) async throws {
    let tests = try await sql.selectWithColumn(RecipeTable.all)
        .from(RecipeTable.tableName)
        .all()
        .eagerLoad(sql: sql, for: \.id, RecipeTable.ingredients.columns {
            IngredientTable.all
        })

    tests.first?.ingredients

}

fileprivate struct S {
    @TypeOf(RecipeTable.title) var foo
    @TypeOf(IngredientTable.name) var bar
}

enum Foo {
    @EraseProperty
    let enumProperty: Int
}
