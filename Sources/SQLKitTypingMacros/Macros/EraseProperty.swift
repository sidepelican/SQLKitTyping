import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct EraseProperty: AccessorMacro {

    // MARK: - Accessor
    public static func expansion(
        of node: AttributeSyntax,
        providingAccessorsOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AccessorDeclSyntax] {
        return [
            """
            @available(*, unavailable)
            get {
                fatalError()
            }
            """,
        ]
    }
}
