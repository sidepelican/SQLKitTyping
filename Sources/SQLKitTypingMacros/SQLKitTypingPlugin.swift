import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct SQLKitTypingPlugin: CompilerPlugin {
    let providingMacros: [any Macro.Type] = [
        Schema.self,
        ChildrenMacro.self,
        EraseProperty.self,
        SQLColumnPropertyType.self,
    ]
}
