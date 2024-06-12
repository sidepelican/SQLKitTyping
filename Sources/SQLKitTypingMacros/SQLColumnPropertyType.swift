import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct SQLColumnPropertyType: DeclarationMacro {
    private struct Arguments {
        var name: String
        var type: String
    }

    private static func extractArguments(from  arguments: LabeledExprListSyntax) throws -> Arguments {
        var name: String?
        var type: String?
        for argument in arguments {
            if argument.label?.text == "type" {
                type = argument.expression.as(MemberAccessExprSyntax.self)?.base?.description
            } else if argument.label?.text == "name" {
                let literal = argument.expression.as(StringLiteralExprSyntax.self)?.representedLiteralValue
                guard let literal else {
                    throw MessageError("StringLiteral expected.")
                }
                name = literal
            }
        }
        guard let name, let type else {
            throw MessageError("unexpected.")
        }
        return .init(name: name, type: type)
    }

    // MARK: - DeclarationMacro

    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        let arguments = try extractArguments(from: node.arguments)

        return [
"""
struct \(raw: arguments.name)<Expr: SQLExpression>: PropertySQLExpression {
    init(_ expr: Expr) { self.expr = expr }
    var expr: Expr
    struct Property: Decodable {
        var \(raw: arguments.name): \(raw: arguments.type)
    }
    @inlinable
    func serializeAsPropertySQLExpression(to serializer: inout SQLSerializer)  {
        SQLAlias(expr, as: "\(raw: arguments.name)").serialize(to: &serializer)
    }
}
"""
        ]
    }
}
