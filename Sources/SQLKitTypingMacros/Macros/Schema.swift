import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct Schema: MemberMacro, PeerMacro, ExtensionMacro {

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
                \(modifiers)struct Property: Decodable, Sendable {
                    \(modifiers)var \(def.varIdentifier): \(def.columnType)
                    \(modifiers)enum CodingKeys: CodingKey {
                        case \(def.varIdentifier)
                        \(modifiers)var stringValue: String { "\\(Schema.tableName)_\(raw: def.columnName)" }
                    }
                }
            }
            """
        }

        var result: [DeclSyntax] = []
        result.append("\(declaration.modifiers.adding(keyword: .static))let all = AllPropertyExpression<\(namedDecl.name.trimmed), \(namedDecl.name.trimmed)>()")
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

        let columnDefs = declGroup.memberBlock.members.compactMap {
            ColumnDefinition(
                decl: $0.decl,
                in: context,
                emitsDiagnostics: false
            )
        }
        let modifiers = declGroup.modifiers.trimmed.with(\.trailingTrivia, .space)

        return [
            DeclSyntax(try EnumDeclSyntax("\(modifiers)enum \(namedDecl.name.trimmed)Types") {
                for def in columnDefs {
                    TypeAliasDeclSyntax(
                        leadingTrivia: .docLineComment("/// => \(def.columnType)").appending(.newline),
                        modifiers: def.modifiers,
                        name: "\(raw: def.columnTypeName)",
                        initializer: TypeInitializerClauseSyntax(
                            value: "\(namedDecl.name.trimmed).\(raw: def.typealiasName).Value" as TypeSyntax
                        )
                    )
                }
            })
        ]
    }

    // MARK: - ExtensionMacro

    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        var conformingTypes: Set<String> = [
            "SchemaProtocol",
        ]
        
        let hasIDProperty = declaration.memberBlock.members.contains { memberBlockItem in
            let def = ColumnDefinition(
                decl: memberBlockItem.decl,
                in: context,
                emitsDiagnostics: false
            )
            return def?.columnName == "id"
        }
        if hasIDProperty {
            conformingTypes.insert("IDSchemaProtocol")
        }

        conformingTypes.subtract(declaration.inheritanceClause?.inheritedTypes.map(\.type.trimmedDescription) ?? [])

        if conformingTypes.isEmpty {
            return []
        }

        return [ExtensionDeclSyntax(
            extendedType: type,
            inheritanceClause: InheritanceClauseSyntax {
                for type in conformingTypes.sorted() {
                    InheritedTypeSyntax(type: TypeSyntax(stringLiteral: type))
                }
            },
            memberBlock: "{}"
        )]
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
