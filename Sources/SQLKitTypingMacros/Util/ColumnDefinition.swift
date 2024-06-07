import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

struct ColumnDefinition {
    /* ex)
     public var `class`: Class
     */

    var varIdentifier: TokenSyntax // `class`
    var columnName: String // class
    var columnTypeName: String // Class_
    var columnType: TypeSyntax // Class
    var typealiasName: String // class
    var modifiers: DeclModifierListSyntax // public

    init?(
        decl: some DeclSyntaxProtocol,
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
        typealiasName = columnName
        modifiers = varDecl.modifiers
    }
}

extension VariableDeclSyntax {
    /// Determine whether this variable has the syntax of a stored property.
    ///
    /// This syntactic check cannot account for semantic adjustments due to,
    /// e.g., accessor macros or property wrappers.
    fileprivate var isStoredProperty: Bool {
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

    fileprivate var isStatic: Bool {
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
        var result = self
        if result.hasPrefix("`") {
            result.removeFirst()
        }
        if result.hasSuffix("`") {
            result.removeLast()
        }
        return result
    }
}
