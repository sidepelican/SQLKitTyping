import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct Column: PeerMacro {
    private struct Arguments {
        var namespace: String
    }

    private static func extractArguments(from attribute: AttributeSyntax) throws -> Arguments {
        guard let arguments = attribute.arguments?.as(LabeledExprListSyntax.self) else {
            throw MessageError("Unexpected argument.")
        }
        var namespace: String = ""
        for argument in arguments {
            if argument.label?.text == "namespace" {
                let literal = argument.expression.as(StringLiteralExprSyntax.self)?.representedLiteralValue
                guard let literal else {
                    throw MessageError("Unexpected literal.")
                }
                namespace = literal
            }
        }
        return .init(namespace: namespace)
    }

    // MARK: - Peer
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        let arguments = try extractArguments(from: node)

        guard let def = ColumnDefinition(
            decl: declaration,
            in: context,
            emitsDiagnostics: false
        ) else {
            return []
        }

        let aliasName = "\(arguments.namespace).\(def.typealiasName)"

        return [
            DeclSyntax(TypeAliasDeclSyntax(
                leadingTrivia: .docLineComment("/// => \(def.columnType.description)").appending(.newline),
                modifiers: def.modifiers.trimmed,
                name: "\(raw: def.columnTypeName)",
                initializer: TypeInitializerClauseSyntax(
                    value: "\(raw: aliasName)" as TypeSyntax
                )
            )),

            "\(def.modifiers.adding(keyword: .static))let \(def.varIdentifier) = Column<\(raw: aliasName)>(\"\(raw: def.columnName)\")",
        ]
    }
}
