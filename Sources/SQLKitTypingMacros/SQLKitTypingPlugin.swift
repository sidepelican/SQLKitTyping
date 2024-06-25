import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct SQLKitTypingPlugin: CompilerPlugin {
    let providingMacros: [any Macro.Type] = [
        Schema.self,
        Children.self,
        Parent.self,
        EraseProperty.self,
        SQLColumnPropertyType.self,
    ]
}
