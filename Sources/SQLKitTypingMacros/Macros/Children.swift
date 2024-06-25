import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct Children: DeclarationMacro {
    private struct Arguments {
        var name: String
        var column: KeyPathExprSyntax
    }

    private static func extractArguments(from arguments: LabeledExprListSyntax) throws -> Arguments {
        var name: String?
        var column: KeyPathExprSyntax?
        for argument in arguments {
            switch argument.label?.text {
            case "name":
                let literal = argument.expression.as(StringLiteralExprSyntax.self)?.representedLiteralValue
                guard let literal else {
                    throw MessageError("StringLiteral expected.")
                }
                name = literal
            case "from":
                column = argument.expression.as(KeyPathExprSyntax.self)
            default:
                break
            }
        }
        guard let name, let column else {
            throw MessageError("unexpected.")
        }
        return .init(name: name, column: column)
    }

    // MARK: - Declaration

    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        let arguments = try extractArguments(from: node.arguments)

        let name = "\(raw: arguments.name)" as TokenSyntax
        guard let schemaType = arguments.column.root else {
            throw MessageError("Must specify root type.")
        }
        let columnRefIdentifier = "\(schemaType)\(arguments.column.components)" as TokenSyntax

        return ["""
        public struct __\(name)Reference: ChildrenReference {
            public struct Property: Decodable {
                public var \(name): [\(schemaType)]
            }
            public let column = \(columnRefIdentifier)
            public var initProperty: ([\(schemaType)]) -> Property {
                return Property.init
            }
        }
        public static func \(name)() -> __\(name)Reference { .init() }
        """]
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
        let columnRefIdentifier = "\(schemaType)\(arguments.column.components)" as TokenSyntax

        let propertyName = binding.pattern.trimmed
        let modifiers = varDecl.modifiers.trimmed.with(\.trailingTrivia, .space)

        return [
            """
            \(modifiers)struct __\(propertyName)<Child: Decodable>: ChildrenProperty, Decodable {
                \(modifiers)var \(propertyName): [Child]
            }
            \(modifiers)static func \(propertyName)<Row: Decodable>() -> _ChildrenReference<some TypedSQLColumn<\(schemaType), Self.ID>, __\(propertyName)<Row>> {
                return .init(
                    column: \(columnRefIdentifier),
                    initProperty: __\(propertyName).init
                )
            }
            """,
        ]
    }
}
