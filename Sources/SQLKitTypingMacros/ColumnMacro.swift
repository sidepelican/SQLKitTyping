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
              stringLiteral.segments.count == 1,
              case let .stringSegment(typePrefixString)? = stringLiteral.segments.first
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
            "\(def.modifiers)typealias \(raw: def.columnTypeName) = \(raw: aliasName)",
            "\(def.modifiers.adding(keyword: .static))let \(def.varIdentifier) = Column<\(raw: aliasName)>(\"\(raw: def.columnName)\")",
        ]
    }
}
