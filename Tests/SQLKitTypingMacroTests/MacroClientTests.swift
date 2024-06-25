import XCTest
import SQLKitTyping

struct RecipeID: Hashable, Codable, Sendable {}
struct PhotoID: Hashable, Codable, Sendable {}

@Schema
struct RecipeModel: IDSchemaProtocol, Codable, Sendable {
    public static var tableName: String { "recipes" }

    var id: RecipeID

    var title: String
    fileprivate var kcal: Int

    #hasMany(
        name: "ingredients",
        mappedBy: \IngredientModel.recipeID
    )

    #hasMany(
        name: "steps",
        mappedBy: \StepModel.recipeID
    )
}

@Schema
struct IngredientModel: SchemaProtocol, Codable, Sendable {
    static var tableName: String { "ingredients" }

    var recipeID: RecipeID

    #hasOne(
        name: "recipe",
        type: RecipeModel.self
    )

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
    var photoID: PhotoID?

    #hasOne(
        name: "recipe",
        type: RecipeModel.self
    )

    #hasOne(
        name: "photo",
        type: PhotoModel.self
    )
}

@Schema
struct PhotoModel: IDSchemaProtocol, Codable, Sendable {
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
            propertyInit: SQL.ingredients.Property.init
        )
        .eagerLoadMany(sql: sql, for: \.id, reference: RecipeModel.steps()) {
            $0.orderBy(StepModel.order)
        }

    _ = tests.first?.ingredients
    _ = tests.first?.steps
}

func g(sql: some SQLDatabase) async throws {
    let tests = try await sql.selectWithColumn(StepModel.all)
        .from(StepModel.tableName)
        .all()
        .eagerLoadOne(sql: sql, mappedBy: \.recipeID, reference: StepModel.recipe())
        .eagerLoadOne(
            idKey: \.photoID,
            fetch: { ids in
                try await sql.selectWithColumn(PhotoModel.all)
                    .from(PhotoModel.self)
                    .where(PhotoModel.id, .in, SQLBind.group(ids))
                    .all()
            },
            mappingKey: \.id,
            propertyInit: SQL.photo.Property.init
        )
        .eagerLoadOne(sql: sql, mappedBy: \.photoID, reference: StepModel.photo())

    _ = tests.first?.recipe.title
    _ = tests.first?.photo?.filename
}

fileprivate struct S {
    var foo: RecipeModelTypes.Title
    var bar: RecipeModelTypes.Kcal
}

enum Foo {
    @EraseProperty
    let enumProperty: Int
}
