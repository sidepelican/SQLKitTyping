import XCTest
import SQLKitTyping

struct RecipeID: Hashable, Codable, Sendable {}
struct PhotoID: Hashable, Codable, Sendable {}

@Schema
fileprivate struct RecipeModel: IDSchemaProtocol, Codable, Sendable {
    public static var tableName: String { "recipes" }

    var id: RecipeID

    var title: String
    fileprivate var kcal: Int

    @Children(for: \IngredientModel.recipeID)
    public var ingredients: Any

    @Children(for: \StepModel.recipeID)
    public var steps: Any
}

@Schema
struct IngredientModel: SchemaProtocol, Codable, Sendable {
    static var tableName: String { "ingredients" }

    var recipeID: RecipeID
    var order: Int
    var name: String
}

@Schema
struct StepModel: SchemaProtocol, Codable, Sendable {
    static var tableName: String { "steps" }

    var recipeID: RecipeID
    var order: Int
    var description: String
    var amount: String
    var photo: PhotoID?
}

@Schema
struct PhotoModel: SchemaProtocol, Codable, Sendable {
    static var tableName: String { "photos" }

    var photoID: PhotoID
    var filename: String
}

func f(sql: some SQLDatabase) async throws {
    let tests = try await sql.selectWithColumn(RecipeModel.all)
        .from(RecipeModel.tableName)
        .all()
        .eagerLoad(sql: sql, for: \.id, RecipeModel.ingredients) {
            IngredientModel.all
        } buildOrderBy: {
            $0.orderBy(IngredientModel.order)
        }
        .eagerLoad(sql: sql, for: \.id, RecipeModel.steps) {
            StepModel.all
        } buildOrderBy: {
            $0.orderBy(StepModel.order)
        }

    _ = tests.first?.ingredients
    _ = tests.first?.steps
}

fileprivate struct S {
    @TypeOf(RecipeModel.title) var foo
    @TypeOf(IngredientModel.name) var bar
}

enum Foo {
    @EraseProperty
    let enumProperty: Int
}
