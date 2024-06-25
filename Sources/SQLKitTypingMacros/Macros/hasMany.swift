import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct hasMany: DeclarationMacro {
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
            case "mappedBy":
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
        public struct __\(name)Reference: HasManyReference {
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
}
