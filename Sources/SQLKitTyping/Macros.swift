@_exported import SQLKit

@attached(member, names: named(All), named(all))
@attached(memberAttribute)
@attached(peer, names: suffixed(_types))
public macro Schema() = #externalMacro(module: "SQLKitTypingMacros", type: "Schema")

@attached(peer, names: arbitrary, overloaded)
public macro Column(namespace: String) = #externalMacro(module: "SQLKitTypingMacros", type: "Column")

@attached(accessor)
public macro EraseProperty() = #externalMacro(module: "SQLKitTypingMacros", type: "EraseProperty")
