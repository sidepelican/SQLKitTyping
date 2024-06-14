import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct Schema: MemberMacro, MemberAttributeMacro, PeerMacro {

    // MARK: - MemberMacro

    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let namedDecl = declaration.asProtocol((any NamedDeclSyntax).self) else {
            return []
        }

        guard let declGroup = declaration.asProtocol((any DeclGroupSyntax).self) else {
            return []
        }

        let columnDefs = declGroup.memberBlock.members.compactMap {
            ColumnDefinition(
                decl: $0.decl,
                in: context,
                emitsDiagnostics: true
            )
        }

        func buildColumnType(def: ColumnDefinition) -> DeclSyntax {
            let modifiers = def.modifiers.with(\.trailingTrivia, .space)

            return """
            \(modifiers)struct \(raw: def.typealiasName): TypedSQLColumn, PropertySQLExpression {
                \(modifiers)typealias Schema = \(namedDecl.name.trimmed)
                \(modifiers)typealias Value = \(def.columnType)
                \(modifiers)var name: String { "\(raw: def.columnName)" }
                \(modifiers)struct Property: Decodable {
                    \(modifiers)var \(def.varIdentifier): \(def.columnType)
                    \(modifiers)enum CodingKeys: CodingKey {
                        case \(def.varIdentifier)
                        \(modifiers)var stringValue: String { "\\(Schema.tableName)_\(raw: def.columnName)" }
                    }
                }
            }
            """
        }

        let modifiers = declGroup.modifiers.trimmed.with(\.trailingTrivia, .space)

        func buildAllType() throws -> StructDeclSyntax {
            return try StructDeclSyntax("\(modifiers)struct __allProperty: Decodable") {
                for (i, def) in columnDefs.enumerated() {
                    let modifiers = def.modifiers.with(\.trailingTrivia, .space)
                    try VariableDeclSyntax(
                        "\(modifiers)var \(def.varIdentifier): \(def.columnType)"
                    )
                    .with(\.leadingTrivia, i != 0 ? .newline : [])
                }
            }
        }

        var result: [DeclSyntax] = []
        result.append(DeclSyntax(try buildAllType()))
        result.append("\(declaration.modifiers.adding(keyword: .static))let all = AllPropertyExpression<\(namedDecl.name.trimmed), __allProperty>()")
        for def in columnDefs {
            result.append(buildColumnType(def: def))
            result.append(DeclSyntax(VariableDeclSyntax(
                leadingTrivia: .docLineComment("/// => \(def.varIdentifier): \(def.columnType.description)").appending(.newline),
                modifiers: def.modifiers.adding(keyword: .static),
                .let,
                name: PatternSyntax("\(def.varIdentifier)"),
                initializer: InitializerClauseSyntax(
                    value: FunctionCallExprSyntax(callee: "\(raw: def.typealiasName)" as ExprSyntax)
                )
            )))
        }
        return result
    }

    // MARK: - MemberAttributeMacro

    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingAttributesFor member: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AttributeSyntax] {
        guard let _ = ColumnDefinition(
            decl: member,
            in: context,
            emitsDiagnostics: false
        ) else {
            return []
        }

        return [
            AttributeSyntax(TypeSyntax("EraseProperty")),
        ]
    }

    // MARK: - Peer

    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let namedDecl = declaration.asProtocol((any NamedDeclSyntax).self),
              let declGroup = declaration.asProtocol((any DeclGroupSyntax).self) else {
            return []
        }

        let modifiers = declGroup.modifiers.trimmed.with(\.trailingTrivia, .space)

        return [
            DeclSyntax(try EnumDeclSyntax("\(modifiers)enum \(namedDecl.name.trimmed)Types") {
                TypeAliasDeclSyntax(
                    modifiers: modifiers,
                    name: "All",
                    initializer: TypeInitializerClauseSyntax(value: "\(namedDecl.name.trimmed).__allProperty" as TypeSyntax)
                )
            })
        ]
    }
}

extension StringProtocol {
    fileprivate func trimmingSuffix(_ pattern: String) -> SubSequence {
        if self.hasSuffix(pattern) {
            return self[startIndex..<index(endIndex, offsetBy: -pattern.count)]
        }
        return self[...]
    }
}
