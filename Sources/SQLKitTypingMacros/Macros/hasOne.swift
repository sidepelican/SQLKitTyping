import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct hasOne: PeerMacro {
    private struct Arguments {
        var column: KeyPathExprSyntax
    }

    private static func extractArguments(from arguments: LabeledExprListSyntax) throws -> Arguments {
        var column: KeyPathExprSyntax?
        for argument in arguments {
            if argument.label?.text == "by" {
                column = argument.expression.as(KeyPathExprSyntax.self)
            }
        }
        guard let column else {
            throw MessageError("unexpected.")
        }
        return .init(column: column)
    }

    // MARK: - Peer

    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let varDecl = declaration.as(VariableDeclSyntax.self),
              let binding = varDecl.bindings.first,
              case .argumentList(let nodeArguments) = node.arguments
        else {
            return []
        }

        let arguments = try extractArguments(from: nodeArguments)
        guard let schemaType = arguments.column.root else {
            throw MessageError("Must specify root type.")
        }
        guard let typeAnnotation = binding.typeAnnotation?.type.trimmed else {
            throw MessageError("Must specify variable type.")
        }
        let columnRefIdentifier = "\(schemaType)\(arguments.column.components)" as TokenSyntax

        let propertyName = binding.pattern.trimmed
        let modifiers = varDecl.modifiers.trimmed.with(\.trailingTrivia, .space)

        return [
            """
            \(modifiers)struct __\(propertyName)<Parent: Decodable>: ParentProperty, Decodable {
                \(modifiers)var \(propertyName): Parent
            }
            \(modifiers)static func \(propertyName)<Row: Decodable>() -> _ParentReference<some TypedSQLColumn<\(schemaType), \(typeAnnotation).ID>, __\(propertyName)<Row>> {
                return .init(
                    column: \(columnRefIdentifier),
                    initProperty: __\(propertyName).init
                )
            }
            """,
        ]
    }

}
