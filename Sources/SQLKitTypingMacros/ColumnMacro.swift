import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct Column: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let varDecl = declaration.as(VariableDeclSyntax.self),
              let binding = varDecl.bindings.first,
              let identifier = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier
        else {
            throw MessageError("unexpected syntax")
        }

        guard varDecl.isStoredProperty else {
            throw MessageError("@Column can add to stored property only")
        }

        let modifiers = varDecl.modifiers
        if modifiers.contains(where: { $0.name.tokenKind == .keyword(.static) }) {
            throw MessageError("@Column cannot apply to static property")
        }

        let columnName = identifier.text
        guard let columnType = binding.typeAnnotation?.type else {
            throw MessageError("missing type annotation")
        }

        return [
            "\(modifiers)typealias \(raw: columnName.capitalized) = \(columnType)",
            "\(modifiers)static let \(raw: columnName) = Column<\(raw: columnName.capitalized)>(\"\(raw: columnName)\")",
        ]
    }
}
