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

    // MARK: - MemberAttributeMacro

    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingAttributesFor member: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AttributeSyntax] {
        if member.as(VariableDeclSyntax.self)?.attributes.contains(where: {
            if case .attribute(let attribute) = $0 {
                return attribute.attributeName.trimmed.description == "Children"
            }
            return false
        }) == true {
            guard declaration.inheritanceClause?.inheritedTypes.contains(where: {
                $0.type.trimmed.description == "IDSchemaProtocol"
            }) == true else {
                let typeName = declaration.asProtocol((any NamedDeclSyntax).self)?.name.description ?? "this type"
                throw MessageError("@Children requires \(typeName) to conform to 'IDSchemaProtocol'")
            }
            return [
                AttributeSyntax(TypeSyntax("EraseProperty")),
            ]
        }
        
        return []
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
                emitsDiagnostics: true
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
}

extension StringProtocol {
    fileprivate func trimmingSuffix(_ pattern: String) -> SubSequence {
        if self.hasSuffix(pattern) {
            return self[startIndex..<index(endIndex, offsetBy: -pattern.count)]
        }
        return self[...]
    }
}
