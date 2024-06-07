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
        guard let namedDecl = declaration.asProtocol(NamedDeclSyntax.self) else {
            return []
        }

        guard let _ = ColumnDefinition(
            decl: member,
            in: context,
            emitsDiagnostics: false
        ) else {
            return []
        }

        return [
            AttributeSyntax(TypeSyntax("EraseProperty")),
            AttributeSyntax("Column") {
                LabeledExprSyntax(
                    label: "namespace",
                    expression: "\(namedDecl.name.trimmed.text)_types".makeLiteralSyntax()
                )
            },
        ]
    }

    // MARK: - Peer

    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let namedDecl = declaration.asProtocol(NamedDeclSyntax.self) else {
            return []
        }

        guard let declGroup = declaration.asProtocol(DeclGroupSyntax.self) else {
            return []
        }

        return [
            DeclSyntax(try EnumDeclSyntax("\(declGroup.modifiers)enum \(namedDecl.name.trimmed)_types") {
                for member in declGroup.memberBlock.members {
                    if let def = ColumnDefinition(
                        decl: member.decl,
                        in: context,
                        emitsDiagnostics: true // エラーが重複するので、エラーはここでだけ出す
                    ) {
                        "\(def.modifiers)typealias \(raw: def.typealiasName) = \(def.columnType)"
                    }
                }
            })
        ]
    }
}
