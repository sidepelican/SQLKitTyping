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

        func buildColumnType(def: ColumnDefinition) -> DeclSyntax {
            let sqlColumnName = "\(namedDecl.name.trimmed)_\(def.columnName)"
            return """
            \(def.modifiers)struct \(raw: def.typealiasName): TypedSQLColumn, PropertySQLExpression {
                \(def.modifiers)typealias Schema = \(namedDecl.name.trimmed)
                \(def.modifiers)typealias Value = \(def.columnType)

                \(def.modifiers)var name: String { "\(raw: def.columnName)" }

                @inlinable
                \(def.modifiers)func serializeAsPropertySQLExpression(to serializer: inout SQLSerializer) {
                    SQLAlias(SQLColumn(name, table: Schema.tableName), as: "\(raw: sqlColumnName)")
                        .serialize(to: &serializer)
                }

                \(def.modifiers)struct Property: Decodable {
                    \(def.modifiers)var \(def.varIdentifier): \(def.columnType)
                    \(def.modifiers)enum CodingKeys: String, CodingKey {
                        case \(def.varIdentifier) = "\(raw: sqlColumnName)"
                    }
                }
            }
            """
        }

        return [
            DeclSyntax(try EnumDeclSyntax("\(declGroup.modifiers)enum \(namedDecl.name.trimmed)_types") {
                for member in declGroup.memberBlock.members {
                    if let def = ColumnDefinition(
                        decl: member.decl,
                        in: context,
                        emitsDiagnostics: true // エラーが重複するので、エラーはここでだけ出す
                    ) {
                        buildColumnType(def: def)
                    }
                }
            })
        ]
    }
}
