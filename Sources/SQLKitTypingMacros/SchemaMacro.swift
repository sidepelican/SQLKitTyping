import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct Schema: MemberAttributeMacro, PeerMacro {

    // MARK: - MemberAttributeMacro
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingAttributesFor member: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AttributeSyntax] {
        guard let declaration = declaration.as(StructDeclSyntax.self) else {
            throw MessageError("struct required for @Schema")
        }

        guard let _ = ColumnDefinition(
            decl: member,
            in: context,
            emitsDiagnostics: false
        ) else {
            return []
        }

        return [AttributeSyntax("Column") {
            LabeledExprSyntax(
                expression: StringLiteralExprSyntax(content: "\(declaration.name.trimmed.text)_types")
            )
        }]
    }

    // MARK: - Peer
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let declaration = declaration.as(StructDeclSyntax.self) else {
            return []
        }

        return [DeclSyntax(
            try EnumDeclSyntax("\(declaration.modifiers)enum \(declaration.name.trimmed)_types") {
                for member in declaration.memberBlock.members {
                    if let def = ColumnDefinition(
                        decl: member.decl,
                        in: context,
                        emitsDiagnostics: true // エラーが重複するので、エラーはここでだけ出す
                    ) {
                        "\(def.modifiers)typealias \(raw: def.typealiasName) = \(def.columnType)"
                    }
                }
            }
        )]
    }
}
