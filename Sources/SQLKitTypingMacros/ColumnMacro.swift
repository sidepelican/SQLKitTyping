import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct Column: PeerMacro {

    // MARK: - Peer
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard case .argumentList(let arguments) = node.arguments,
              let firstElement = arguments.first,
              let stringLiteral = firstElement.expression.as(StringLiteralExprSyntax.self),
              let typePrefixString = stringLiteral.representedLiteralValue
        else {
            throw MessageError("@Column macro requires a string literal")
        }

        guard let def = ColumnDefinition(
            decl: declaration,
            in: context,
            emitsDiagnostics: false
        ) else {
            return []
        }

        let aliasName = "\(typePrefixString).\(def.typealiasName)"

        return [
            TypeAliasDeclSyntax(
                leadingTrivia: .docLineComment("/// => \(def.columnType.description)").appending(.newline),
                modifiers: def.modifiers.trimmed,
                name: "\(raw: def.columnTypeName)",
                initializer: TypeInitializerClauseSyntax(
                    value: "\(raw: aliasName)" as TypeSyntax
                )
            ).cast(DeclSyntax.self),

            "\(def.modifiers.adding(keyword: .static))let \(def.varIdentifier) = Column<\(raw: aliasName)>(\"\(raw: def.columnName)\")",
        ]
    }
}
