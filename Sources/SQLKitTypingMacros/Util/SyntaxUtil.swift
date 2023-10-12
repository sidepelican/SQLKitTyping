import SwiftSyntax

extension DeclModifierListSyntax {
    func adding(keyword: Keyword) -> Self {
        var result = self
        if !result.contains(where: { $0.name.tokenKind == .keyword(keyword) }) {
            result.append(.init(name: .keyword(keyword)))
            result = result.with(\.trailingTrivia, .spaces(1))
        }
        return result
    }

    func removing(keyword: Keyword) -> Self {
        var result = self
        if let i = result.firstIndex(where: { $0.name.tokenKind == .keyword(keyword) }) {
            result.remove(at: i)
            result = result.with(\.trailingTrivia, .spaces(result.isEmpty ? 0 : 1))
        }
        return result
    }
}

extension TypeSyntax {
    var typeIdentifiers: AnyIterator<String> {
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
