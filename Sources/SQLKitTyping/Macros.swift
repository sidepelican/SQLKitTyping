@_exported import SQLKit

@attached(member, names: arbitrary, named(all), named(__allProperty))
@attached(memberAttribute)
@attached(peer, names: suffixed(Types))
public macro Schema() = #externalMacro(module: "SQLKitTypingMacros", type: "Schema")

@attached(accessor)
public macro EraseProperty() = #externalMacro(module: "SQLKitTypingMacros", type: "EraseProperty")

@freestanding(declaration, names: arbitrary)
public macro SQLColumnPropertyType(name: String) = #externalMacro(module: "SQLKitTypingMacros", type: "SQLColumnPropertyType")

@attached(accessor)
@attached(peer, names: prefixed(__), overloaded)
public macro Children<Schema: SchemaProtocol, T: Equatable>(for column: KeyPath<Schema, T>) = #externalMacro(module: "SQLKitTypingMacros", type: "ChildrenMacro")
