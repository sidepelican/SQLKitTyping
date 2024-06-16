import XCTest
import SQLKitTyping

//macro Children() = #externalMacro(module: "", type: "")

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

    struct __ingredients<Child: Decodable>: ChildrenProperty, Decodable {
        var ingredients: [Child]
    }
    static func ingredients<Row: Decodable>() -> GenericReference<some TypedSQLColumn<IngredientTable, RecipeID>, __ingredients<Row>> {
        return .init(
            column: IngredientTable.recipeID,
            initProperty: __ingredients.init
        )
    }
}

@Schema
enum IngredientTable: SchemaProtocol {
    static var tableName: String { "ingredients" }

    var recipeID: RecipeID
    var order: Int
    var name: String
}

func f(sql: some SQLDatabase) async throws {
    let tests = try await sql.selectWithColumn(RecipeTable.all)
        .from(RecipeTable.tableName)
        .all()
        .eagerLoad(sql: sql, for: \.id, RecipeTable.ingredients) {
            IngredientTable.all
        }

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
