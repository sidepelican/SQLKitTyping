import XCTest
import SQLKitTyping

struct RecipeID: Hashable, Codable, Sendable {}
struct PhotoID: Hashable, Codable, Sendable {}

@Schema
struct RecipeModel: Sendable {
    public static var tableName: String { "recipes" }

    var id: RecipeID

    var title: String
    fileprivate var kcal: Int

    #hasMany(
        propertyName: "ingredients",
        mappedBy: \IngredientModel.recipeID
    )

    #hasMany(
        propertyName: "steps",
        mappedBy: \StepModel.recipeID
    )
}

@Schema
struct IngredientModel: SchemaProtocol, Sendable {
    static var tableName: String { "ingredients" }

    var recipeID: RecipeID

    #hasOne(
        propertyName: "recipe",
        type: RecipeModel.self
    )

    var order: Int
    var name: String
}

@Schema
struct StepModel: Sendable {
    static var tableName: String { "steps" }

    var recipeID: RecipeID
    var order: Int
    var description: String
    var amount: String
    var photoID: PhotoID?

    #hasOne(
        propertyName: "recipe",
        type: RecipeModel.self
    )

    #hasOne(
        propertyName: "photo",
        type: PhotoModel.self
    )
}

@Schema
struct PhotoModel: Sendable {
    static var tableName: String { "photos" }

    var id: PhotoID
    var filename: String
}

enum SQL {
    #SQLColumnPropertyType(name: "photo")
    #SQLColumnPropertyType(name: "ingredients")
}

func f(sql: some SQLDatabase) async throws {
    let tests = try await sql.selectWithColumn(RecipeModel.all)
        .from(RecipeModel.tableName)
        .all()
        .eagerLoadMany(
            idKey: \.id,
            fetch: { ids in
                try await sql.selectWithColumn(IngredientModel.all)
                    .from(IngredientModel.self)
                    .where(IngredientModel.recipeID, .in, SQLBind.group(ids))
                    .all()
            },
            mappingKey: \.recipeID,
            propertyInit: RecipeModel.ingredients.init
        )
        .eagerLoadMany(sql: sql, for: \.id, using: RecipeModel.steps.self) {
            $0.orderBy(StepModel.order)
        }

    _ = tests.first?.ingredients
    _ = tests.first?.steps
}

func g(sql: some SQLDatabase) async throws {
    let tests = try await sql.selectWithColumn(StepModel.all)
        .from(StepModel.tableName)
        .all()
        .eagerLoadOne(sql: sql, mappedBy: \.recipeID, using: StepModel.recipe.self)
        .eagerLoadOne(
            idKey: \.photoID,
            fetch: { ids in
                try await sql.selectWithColumn(PhotoModel.all)
                    .from(PhotoModel.self)
                    .where(PhotoModel.id, .in, SQLBind.group(ids))
                    .all()
            },
            mappingKey: \.id,
            propertyInit: StepModel.photo.init
        )
        .eagerLoadOne(sql: sql, mappedBy: \.photoID, using: StepModel.photo.self)

    _ = tests.first?.recipe.title
    _ = tests.first?.photo?.filename
}

fileprivate struct S {
    var foo: RecipeModelTypes.Title
    var bar: RecipeModelTypes.Kcal
}

enum Foo {
    @EraseProperty
    var enumProperty: Int
}
