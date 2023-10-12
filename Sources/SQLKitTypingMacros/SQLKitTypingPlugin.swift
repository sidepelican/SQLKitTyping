import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct SQLKitTypingPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        Schema.self,
        Column.self,
        EraseProperty.self,
    ]
}
