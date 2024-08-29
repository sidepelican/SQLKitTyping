@_exported import SQLKit

@attached(member, names: arbitrary, named(all), named(__allProperty))
@attached(peer, names: suffixed(Types))
public macro Schema() = #externalMacro(module: "SQLKitTypingMacros", type: "Schema")

@attached(accessor)
public macro EraseProperty() = #externalMacro(module: "SQLKitTypingMacros", type: "EraseProperty")

@freestanding(declaration, names: arbitrary)
public macro SQLColumnPropertyType(name: String) = #externalMacro(module: "SQLKitTypingMacros", type: "SQLColumnPropertyType")

@freestanding(declaration, names: arbitrary)
public macro hasMany<Schema: SchemaProtocol, T: Equatable>(
    propertyName: String,
    mappedBy column: KeyPath<Schema, T>
) = #externalMacro(module: "SQLKitTypingMacros", type: "hasMany")

@freestanding(declaration, names: arbitrary)
public macro hasOne<Model: Decodable & IDSchemaProtocol>(
    propertyName: String,
    type: Model.Type
) = #externalMacro(module: "SQLKitTypingMacros", type: "hasOne")
