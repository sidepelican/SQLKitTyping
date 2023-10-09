import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
import SQLKitTypingMacros

private let schemaMacro: [String: Macro.Type] = [
    "Schema": Schema.self,
]

private let columnMacro: [String: Macro.Type] = [
    "Column": Column.self,
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
    @Column
    var value: Int
}
""",
macros: schemaMacro
        )
    }

    func testSchemaMacroIgnoresNotStoredProperty() throws {
        assertMacroExpansion(
"""
@Schema
struct Test {
    static var tableName: String { "foo" }
    var computed: Int { 42 }
}
""",
expandedSource: """
struct Test {
    static var tableName: String { "foo" }
    var computed: Int { 42 }
}
""",
macros: schemaMacro
        )
    }

    // MARK: - @Column

    func testColumnMacro() throws {
        assertMacroExpansion(
"""
struct Test {
    @Column var value: Int
    @Column public var value2: Int?
}
""",
expandedSource: """
struct Test {
    var value: Int

    typealias Value = Int

    static let value = Column<Value>("value")
    public var value2: Int?

    public typealias Value2 = Int?

    public static let value2 = Column<Value2>("value2")
}
""",
macros: columnMacro
        )
    }

    func testColumnMacroIgnoresNotStoredProperty() throws {
        assertMacroExpansion(
"""
struct Test {
    @Column static let tableName: String = "foo"
    @Column var computed: Int { 42 }
    @Column var wrapper = ""
}
""",
expandedSource: """
struct Test {
    static let tableName: String = "foo"
    var computed: Int { 42 }
    var wrapper = ""
}
""",
diagnostics: [
    .init(message: "@Column cannot apply to static property", line: 2, column: 5),
    .init(message: "@Column can add to stored property only", line: 3, column: 5),
    .init(message: "missing type annotation", line: 4, column: 5),
],
macros: columnMacro
        )
    }
}
