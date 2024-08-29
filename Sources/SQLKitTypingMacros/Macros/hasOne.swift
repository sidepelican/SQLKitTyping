import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct hasOne: DeclarationMacro {
    private struct Arguments {
        var propertyName: String
        var type: MemberAccessExprSyntax
    }

    private static func extractArguments(from arguments: LabeledExprListSyntax) throws -> Arguments {
        var propertyName: String?
        var type: MemberAccessExprSyntax?
        for argument in arguments {
            switch argument.label?.text {
            case "propertyName":
                let literal = argument.expression.as(StringLiteralExprSyntax.self)?.representedLiteralValue
                guard let literal else {
                    throw MessageError("StringLiteral expected.")
                }
                propertyName = literal
            case "type":
                type = argument.expression.as(MemberAccessExprSyntax.self)
            default:
                break
            }
        }
        guard let propertyName, let type else {
            throw MessageError("unexpected.")
        }
        return .init(propertyName: propertyName, type: type)
    }

    // MARK: - Declaration

    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        let arguments = try extractArguments(from: node.arguments)

        let name = "\(raw: arguments.propertyName)" as TokenSyntax
        guard let schemaType = arguments.type.base else {
            throw MessageError("Must specify root type.")
        }

        return ["""
        public struct \(name): Decodable, HasOneReference {
            public var \(name): \(schemaType)
            public typealias Property = Self
            public static var initProperty: (\(schemaType)) -> Property {
                return Property.init
            }
        }
        """]
    }
}
