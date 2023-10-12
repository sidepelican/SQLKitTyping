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

        var attributes = [
            AttributeSyntax("Column") {
                LabeledExprSyntax(
                    expression: "\(namedDecl.name.trimmed.text)_types".makeLiteralSyntax()
                )
            },
        ]

        if declaration.is(EnumDeclSyntax.self) {
            attributes.append(AttributeSyntax(TypeSyntax("EraseProperty")))
        }

        return attributes
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
            try EnumDeclSyntax("\(declGroup.modifiers)enum \(namedDecl.name.trimmed)_types") {
                for member in declGroup.memberBlock.members {
                    if let def = ColumnDefinition(
                        decl: member.decl,
                        in: context,
                        emitsDiagnostics: true // エラーが重複するので、エラーはここでだけ出す
                    ) {
                        "\(def.modifiers)typealias \(raw: def.typealiasName) = \(def.columnType)"
                    }
                }
            }.cast(DeclSyntax.self)
        ]
    }
}
