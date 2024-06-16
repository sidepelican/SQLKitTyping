import XCTest
import SQLKitTyping

struct RecipeID: Hashable, Codable, Sendable {}
struct IngredientID: Hashable, Codable, Sendable {}

@Schema
fileprivate enum RecipeTable: IDSchemaProtocol {
    public static var tableName: String { "recipes" }

    var id: RecipeID

    var title: String
    fileprivate var kcal: Int

    @Children(for: \IngredientTable.recipeID)
    public var ingredients: Any

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
