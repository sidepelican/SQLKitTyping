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
        guard let namedDecl = declaration.asProtocol(NamedDeclSyntax.self) else {
            return []
        }

        return [
            DeclSyntax(TypeAliasDeclSyntax(
                modifiers: declaration.modifiers.trimmed,
                name: "All",
                initializer: TypeInitializerClauseSyntax(value: "\(namedDecl.name.trimmed)_types.__all.Property" as TypeSyntax)
            )),
            "\(declaration.modifiers.adding(keyword: .static))let all = \(namedDecl.name.trimmed)_types.__all()",
        ]
    }

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


        let columnDefs = declGroup.memberBlock.members.compactMap {
            ColumnDefinition(
                decl: $0 .decl,
                in: context,
                emitsDiagnostics: true // エラーが重複するので、エラーはここでだけ出す
            )
        }

        func buildColumnType(def: ColumnDefinition) -> DeclSyntax {
            let firstName = namedDecl.name.trimmed.description
                .trimmingSuffix("Schema")
                .trimmingSuffix("Table")
            let sqlColumnName = "\(firstName)_\(def.columnName)"
            let modifiers = def.modifiers.trimmed.with(\.trailingTrivia, .space)

            return """
            \(modifiers)struct \(raw: def.typealiasName): TypedSQLColumn, PropertySQLExpression {
                \(modifiers)typealias Schema = \(namedDecl.name.trimmed)
                \(modifiers)typealias Value = \(def.columnType)

                \(modifiers)var name: String { "\(raw: def.columnName)" }

                @inlinable
                \(modifiers)func serializeAsPropertySQLExpression(to serializer: inout SQLSerializer) {
                    SQLAlias(SQLColumn(name, table: Schema.tableName), as: "\(raw: sqlColumnName)")
                        .serialize(to: &serializer)
                }

                \(modifiers)struct Property: Decodable {
                    \(modifiers)var \(def.varIdentifier): \(def.columnType)
                    \(modifiers)enum CodingKeys: String, CodingKey {
                        case \(def.varIdentifier) = "\(raw: sqlColumnName)"
                    }
                }
            }
            """
        }

        func buildAllType() throws -> DeclSyntax {
            let modifiers = declGroup.modifiers.trimmed.with(\.trailingTrivia, .space)
            let properties = try MemberBlockItemListSyntax {
                for def in columnDefs {
                    try VariableDeclSyntax(
                        "\(def.modifiers.trimmed) var \(def.varIdentifier): \(def.columnType)"
                    ).with(\.trailingTrivia, .newline)
                }
            }
            return """
            \(modifiers)struct __all: PropertySQLExpression {
                \(modifiers)typealias Schema = \(namedDecl.name.trimmed)

                @inlinable
                \(modifiers)var withTable: SQLAllColumn {
                    SQLAllColumn(table: Schema.tableName, serializeTable: true)
                }

                @inlinable
                \(modifiers)func serializeAsPropertySQLExpression(to serializer: inout SQLSerializer) {
                    withTable.serialize(to: &serializer)
                }

                \(modifiers)struct Property: Decodable {
                    \(properties)
                }
            }
            """
        }

        return [
            DeclSyntax(try EnumDeclSyntax("\(declGroup.modifiers)enum \(namedDecl.name.trimmed)_types") {
                try buildAllType()
                for def in columnDefs {
                    buildColumnType(def: def)
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
