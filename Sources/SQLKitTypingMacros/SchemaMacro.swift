import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct Schema: MemberMacro, PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let enumDecl = declaration.as(EnumDeclSyntax.self) else {
            throw MessageError("enum required for @Schema")
        }

        return enumDecl.memberBlock.members.flatMap { member -> [DeclSyntax] in
            guard let def = ColumnDefinition(
                parent: enumDecl,
                decl: member.decl,
                in: context,
                emitsDiagnostics: true
            ) else {
                return []
            }

            return [
                "\(def.modifiers)typealias \(raw: def.columnTypeName) = \(raw: def.typealiasName)",
                "\(def.modifiers.adding(keyword: .static))let \(def.varIdentifier) = Column<\(raw: def.typealiasName)>(\"\(raw: def.columnName)\")",
            ]
        }
    }

    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let enumDecl = declaration.as(EnumDeclSyntax.self) else {
            return []
        }
        return enumDecl.memberBlock.members.compactMap { member in
            guard let def = ColumnDefinition(
                parent: enumDecl,
                decl: member.decl,
                in: context,
                emitsDiagnostics: false // 上のマクロとエラーが重複するので、こちらではエラーをthrowしない
            ) else {
                return nil
            }

            var modifiersWithoutStatic = def.modifiers
            if let i = modifiersWithoutStatic.firstIndex(where: { $0.name.tokenKind == .keyword(.static) }) {
                modifiersWithoutStatic.remove(at: i)
                modifiersWithoutStatic = modifiersWithoutStatic.with(\.trailingTrivia, .spaces(1))
            }

            return "\(modifiersWithoutStatic)typealias \(raw: def.typealiasName) = \(def.columnType)"
        }
    }
}

fileprivate struct ColumnDefinition {
    /* ex)
        public var `class`: Class
     */

    var varIdentifier: TokenSyntax // `class`
    var columnName: String // class
    var columnTypeName: String // Class_
    var columnType: TypeSyntax // Class
    var typealiasName: String // __macro_Foo_class
    var modifiers: DeclModifierListSyntax // public

    init?(
        parent: EnumDeclSyntax,
        decl: DeclSyntax,
        in context: some MacroExpansionContext,
        emitsDiagnostics: Bool
    ) {
        guard let varDecl = decl.as(VariableDeclSyntax.self),
              varDecl.isStoredProperty,
              !varDecl.isStatic
        else {
            return nil
        }

        guard let binding = varDecl.bindings.first,
              let identifier = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier
        else {
            if emitsDiagnostics {
                context.addDiagnostics(from: MessageError("unexpected syntax"), node: decl)
            }
            return nil
        }
        varIdentifier = identifier

        columnName = identifier.text.trimmingBacktick
        guard let columnType = binding.typeAnnotation?.type else {
            if emitsDiagnostics {
                context.addDiagnostics(from: MessageError("missing type annotation"), node: decl)
            }
            return nil
        }
        self.columnType = columnType
        self.columnTypeName = columnName.firstUpper
        typealiasName = "__macro_\(parent.name.text)_\(columnName)"
        modifiers = varDecl.modifiers
    }
}

extension VariableDeclSyntax {
    /// Determine whether this variable has the syntax of a stored property.
    ///
    /// This syntactic check cannot account for semantic adjustments due to,
    /// e.g., accessor macros or property wrappers.
    var isStoredProperty: Bool {
        if bindings.count != 1 {
            return false
        }

        let binding = bindings.first!
        switch binding.accessorBlock?.accessors {
        case .none:
            return true

        case .accessors(let accessors):
            for accessor in accessors {
                switch accessor.accessorSpecifier.tokenKind {
                case .keyword(.willSet), .keyword(.didSet):
                    // Observers can occur on a stored property.
                    break

                default:
                    // Other accessors make it a computed property.
                    return false
                }
            }

            return true

        case .getter:
            return false
        }
    }

    var isStatic: Bool {
        modifiers.contains(where: { $0.name.tokenKind == .keyword(.static) })
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

extension DeclModifierListSyntax {
    fileprivate func adding(keyword: Keyword) -> Self {
        var result = self
        if !result.contains(where: { $0.name.tokenKind == .keyword(keyword) }) {
            result.append(.init(name: .keyword(keyword)))
            result = result.with(\.trailingTrivia, .spaces(1))
        }
        return result
    }

    fileprivate func removing(keyword: Keyword) -> Self {
        var result = self
        if let i = result.firstIndex(where: { $0.name.tokenKind == .keyword(keyword) }) {
            result.remove(at: i)
            result = result.with(\.trailingTrivia, .spaces(result.isEmpty ? 0 : 1))
        }
        return result
    }
}
