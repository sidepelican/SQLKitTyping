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

//    @Parent(by: \Self.recipeID)
//    var recipe: RecipeModel

//    public struct __recipe<Child: Decodable>: ParentProperty, Decodable {
//        public var recipe: Child
//    }
//    public static func recipe<Row: Decodable>() -> _ParentReference<some TypedSQLColumn<Self, RecipeModel.ID>, __recipe<Row>> {
//        return .init(
//            column: Self.recipeID,
//            initProperty: __recipe.init
//        )
//    }

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

struct Ingredients<T: Decodable>: Decodable {
    var ingredients: [T]
}

func f(sql: some SQLDatabase) async throws {

    let tests = try await sql.selectWithColumn(RecipeModel.all)
        .from(RecipeModel.tableName)
        .all()
        .eagerLoad(
            idKey: \.id,
            fetch: { ids in
                try await sql.selectWithColumn(IngredientModel.all)
                    .from(IngredientModel.self)
                    .where(IngredientModel.recipeID, .in, SQLBind.group(ids))
                    .all()
            },
            mappingKey: \.recipeID,
            propertyInit: Ingredients<IngredientModel>.init
        )
        .eagerLoad(sql: sql, for: \.id, reference: RecipeModel.steps()) {
            $0.orderBy(StepModel.order)
        }

    _ = tests.first?.ingredients
    _ = tests.first?.steps
}

fileprivate struct S {
    var foo: RecipeModelTypes.Title
    var bar: RecipeModelTypes.Kcal
}

enum Foo {
    @EraseProperty
    let enumProperty: Int
}
