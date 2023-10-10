import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct Column: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let varDecl = declaration.as(VariableDeclSyntax.self),
              let binding = varDecl.bindings.first,
              let identifier = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier
        else {
            throw MessageError("unexpected syntax")
        }

        guard varDecl.isStoredProperty else {
            throw MessageError("@Column can add to stored property only")
        }

        let modifiers = varDecl.modifiers
        if modifiers.contains(where: { $0.name.tokenKind == .keyword(.static) }) {
            throw MessageError("@Column cannot apply to static property")
        }

        let columnName = identifier.text.trimmingBacktick
        guard let columnType = binding.typeAnnotation?.type else {
            throw MessageError("missing type annotation")
        }

        var columnTypeName = columnName.firstUpper
        if columnType.typeIdentifiers.contains(columnTypeName) {
            columnTypeName += "Type"
        }

        return [
            "\(modifiers)typealias \(raw: columnTypeName) = \(columnType)",
            "\(modifiers)static let \(identifier) = Column<\(raw: columnTypeName)>(\"\(raw: columnName)\")",
        ]
    }
}

extension String {
    fileprivate var firstUpper: String {
        guard !isEmpty else { return self }

        var result = self
        let firstLetter = self[startIndex...startIndex].uppercased()
        result.replaceSubrange(startIndex...startIndex, with: firstLetter)
        return result
    }

    fileprivate var trimmingBacktick: String {
        self.trimmingCharacters(in: ["`"])
    }
}

extension TypeSyntax {
    fileprivate var typeIdentifiers: AnyIterator<String> {
        var stack: [TypeSyntax] = [self]
        return .init { () -> String? in
            while let next = stack.popLast() {
                if let optional = next.as(OptionalTypeSyntax.self) {
                    stack.append(optional.wrappedType)
                    continue
                }

                if let identifier = next.as(IdentifierTypeSyntax.self) {
                    if let genericArguments = identifier.genericArgumentClause {
                        stack.append(contentsOf: genericArguments.arguments.map(\.argument))
                    }
                    return identifier.name.text
                }

                // unsupported. (ex: FunctionType, TupleType
            }

            return nil
        }
    }
}
