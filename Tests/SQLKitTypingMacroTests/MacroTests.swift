import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
import SQLKitTypingMacros

private let schemaMacro: [String: Macro.Type] = [
    "Schema": Schema.self,
]

final class MacroTests: XCTestCase {
    // MARK: - @Schema

    func testSchemaMacro() throws {
        assertMacroExpansion(
"""
@Schema
enum Test {
    var value: Int
}
""",
expandedSource: """
enum Test {
    var value: Int

    typealias Value = __macro_Test_value

    static let value = Column<__macro_Test_value>("value")
}

typealias __macro_Test_value = Int
""",
macros: schemaMacro
        )
    }

    func testSchemaMacroModifiers() throws {
        assertMacroExpansion(
"""
@Schema
enum Test {
    public var fooBar: Int?
}
""",
expandedSource: """
enum Test {
    public var fooBar: Int?

    public typealias FooBar = __macro_Test_fooBar

    public static let fooBar = Column<__macro_Test_fooBar>("fooBar")
}

public typealias __macro_Test_fooBar = Int?
""",
macros: schemaMacro
        )
    }

    func testSchemaMacroIgnoresNotStoredProperty() throws {
        assertMacroExpansion(
"""
@Schema
enum Test {
    static let tableName: String = "foo"
    var computed: Int { 42 }
}
""",
expandedSource: """
enum Test {
    static let tableName: String = "foo"
    var computed: Int { 42 }
}
""",
macros: schemaMacro
        )
    }

    func testSchemaMacroErrorsNoTypeAnnotation() throws {
        assertMacroExpansion(
"""
@Schema
enum Test {
    var wrapper = ""
}
""",
expandedSource: """
enum Test {
    var wrapper = ""
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
enum Test {
    var `class`: Class
    var `struct`: Int
}
""",
expandedSource: """
enum Test {
    var `class`: Class
    var `struct`: Int

    typealias Class = __macro_Test_class

    static let `class` = Column<__macro_Test_class>("class")

    typealias Struct = __macro_Test_struct

    static let `struct` = Column<__macro_Test_struct>("struct")
}

typealias __macro_Test_class = Class

typealias __macro_Test_struct = Int
""",
macros: schemaMacro
        )
    }
}
