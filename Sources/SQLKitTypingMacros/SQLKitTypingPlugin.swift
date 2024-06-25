import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct SQLKitTypingPlugin: CompilerPlugin {
    let providingMacros: [any Macro.Type] = [
        Schema.self,
        hasMany.self,
        hasOne.self,
        EraseProperty.self,
        SQLColumnPropertyType.self,
    ]
}
