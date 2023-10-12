import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(SQLKitTypingMacros)
import SQLKitTypingMacros

private let allMacro: [String: Macro.Type] = [
    "Schema": Schema.self,
    "Column": Column.self,
    "EraseProperty": EraseProperty.self,
]

private let schemaMacro: [String: Macro.Type] = [
    "Schema": Schema.self,
]

final class MacroTests: XCTestCase {
    // MARK: - @Schema

    func testSchemaMacro() throws {
        assertMacroExpansion(
"""
@Schema
struct Test {
    var value: Int
}
""",
expandedSource: """
struct Test {
    var value: Int {
        @available(*, unavailable)
        get {
            fatalError()
        }
    }

    /// => Int
    typealias Value = Test_types.__macro_value

    static let value = Column<Test_types.__macro_value>("value")
}

enum Test_types {
    typealias __macro_value = Int
}
""",
macros: allMacro
        )
    }

    func testSchemaMacroModifiers() throws {
        assertMacroExpansion(
"""
@Schema
public struct Test {
    public var fooBar: Int?
}
""",
expandedSource: """
public struct Test {
    @EraseProperty @Column("Test_types")
    public var fooBar: Int?
}

public enum Test_types {
    public typealias __macro_fooBar = Int?
}
""",
macros: [
    "Schema": Schema.self,
]
        )
    }

    func testSchemaMacroIgnoresNotStoredProperty() throws {
        assertMacroExpansion(
"""
@Schema
struct Test {
    static let tableName: String = "foo"
    var computed: Int { 42 }
}
""",
expandedSource: """
struct Test {
    static let tableName: String = "foo"
    var computed: Int { 42 }
}

enum Test_types {
}
""",
macros: schemaMacro
        )
    }

    func testSchemaMacroErrorsNoTypeAnnotation() throws {
        assertMacroExpansion(
"""
@Schema
struct Test {
    var wrapper = ""
}
""",
expandedSource: """
struct Test {
    var wrapper = ""
}

enum Test_types {
}
""",
diagnostics: [
    .init(message: "missing type annotation", line: 3, column: 5),
],
macros: schemaMacro
        )
    }

    func testSchemaMacroTrimBacktick() throws {
        assertMacroExpansion(
"""
@Schema
struct Test {
    var `class`: Class
    var `struct`: Int
}
""",
expandedSource: """
struct Test {
    var `class`: Class {
        @available(*, unavailable)
        get {
            fatalError()
        }
    }

    /// => Class
    typealias Class = Test_types.__macro_class

    static let `class` = Column<Test_types.__macro_class>("class")
    var `struct`: Int {
        @available(*, unavailable)
        get {
            fatalError()
        }
    }

    /// => Int
    typealias Struct = Test_types.__macro_struct

    static let `struct` = Column<Test_types.__macro_struct>("struct")
}

enum Test_types {
    typealias __macro_class = Class
    typealias __macro_struct = Int
}
""",
macros: allMacro
        )
    }

    func testSchemaAddErasePropertyForEnum() throws {
        assertMacroExpansion(
"""
@Schema
enum Test {
    var value: Int
}
""",
expandedSource: """
enum Test {
    @EraseProperty @Column("Test_types")
    var value: Int
}

enum Test_types {
    typealias __macro_value = Int
}
""",
macros: schemaMacro 
        )
    }
}
#endif
