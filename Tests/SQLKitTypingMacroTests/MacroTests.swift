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
    @Column public var fooBar: Int?
}
""",
expandedSource: """
struct Test {
    var value: Int

    typealias Value = Int

    static let value = Column<Value>("value")
    public var fooBar: Int?

    public typealias FooBar = Int?

    public static let fooBar = Column<FooBar>("fooBar")
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

    func testColumnMacroAvoidTypealiasReferencesItself() throws {
        assertMacroExpansion(
"""
struct Test {
    @Column var foo: Foo
    @Column var bar: Bar?
    @Column var baz: MyModule.Baz
}
""",
expandedSource: """
struct Test {
    var foo: Foo

    typealias FooType = Foo

    static let foo = Column<FooType>("foo")
    var bar: Bar?

    typealias BarType = Bar?

    static let bar = Column<BarType>("bar")
    var baz: MyModule.Baz

    typealias Baz = MyModule.Baz

    static let baz = Column<Baz>("baz")
}
""",
macros: columnMacro
        )
    }

    func testColumnMacroTrimBacktick() throws {
        assertMacroExpansion(
"""
struct Test {
    @Column var `class`: Class
    @Column var `struct`: Int
}
""",
expandedSource: """
struct Test {
    var `class`: Class

    typealias ClassType = Class

    static let `class` = Column<ClassType>("class")
    var `struct`: Int

    typealias Struct = Int

    static let `struct` = Column<Struct>("struct")
}
""",
macros: columnMacro
        )
    }
}
