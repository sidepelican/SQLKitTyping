import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct hasMany: DeclarationMacro {
    private struct Arguments {
        var propertyName: String
        var column: KeyPathExprSyntax
    }

    private static func extractArguments(from arguments: LabeledExprListSyntax) throws -> Arguments {
        var propertyName: String?
        var column: KeyPathExprSyntax?
        for argument in arguments {
            switch argument.label?.text {
            case "propertyName":
                let literal = argument.expression.as(StringLiteralExprSyntax.self)?.representedLiteralValue
                guard let literal else {
                    throw MessageError("StringLiteral expected.")
                }
                propertyName = literal
            case "mappedBy":
                column = argument.expression.as(KeyPathExprSyntax.self)
            default:
                break
            }
        }
        guard let propertyName, let column else {
            throw MessageError("unexpected.")
        }
        return .init(propertyName: propertyName, column: column)
    }

    // MARK: - Declaration

    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        let arguments = try extractArguments(from: node.arguments)

        let name = "\(raw: arguments.propertyName)" as TokenSyntax
        guard let schemaType = arguments.column.root else {
            throw MessageError("Must specify root type.")
        }
        let columnRefIdentifier = "\(schemaType)\(arguments.column.components)" as TokenSyntax

        return ["""
        public struct \(name): Decodable, HasManyReference {
            public var \(name): [\(schemaType)]

            public static let column = \(columnRefIdentifier)
            public typealias Property = Self
            public static var initProperty: ([\(schemaType)]) -> Property {
                return Property.init
            }
        }
        """]
    }
}
