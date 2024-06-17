import XCTest
import SQLKitTyping

struct RecipeID: Hashable, Codable, Sendable {}
struct IngredientID: Hashable, Codable, Sendable {}

@Schema
fileprivate struct RecipeModel: IDSchemaProtocol, Codable, Sendable {
    public static var tableName: String { "recipes" }

    var id: RecipeID

    var title: String
    fileprivate var kcal: Int

    @Children(for: \IngredientModel.recipeID)
    public var ingredients: Any

}

@Schema
struct IngredientModel: SchemaProtocol, Codable, Sendable {
    static var tableName: String { "ingredients" }

    var recipeID: RecipeID
    var order: Int
    var name: String
}

func f(sql: some SQLDatabase) async throws {
    let tests = try await sql.selectWithColumn(RecipeModel.all)
        .from(RecipeModel.tableName)
        .all()
        .eagerLoad(sql: sql, for: \.id, RecipeModel.ingredients) {
            IngredientModel.all
        }

    _ = tests.first?.ingredients
}

fileprivate struct S {
    @TypeOf(RecipeModel.title) var foo
    @TypeOf(IngredientModel.name) var bar
}

enum Foo {
    @EraseProperty
    let enumProperty: Int
}
