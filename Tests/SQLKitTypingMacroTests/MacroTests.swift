import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(SQLKitTypingMacros)
import SQLKitTypingMacros

private let allMacro: [String: any Macro.Type] = [
    "Schema": Schema.self,
    "EraseProperty": EraseProperty.self,
]

private let schemaMacro: [String: any Macro.Type] = [
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
expandedSource: #"""
struct Test {
    var value: Int

    static let all = AllPropertyExpression<Test, Test>()

    struct __value: TypedSQLColumn, PropertySQLExpression {
        typealias Schema = Test
        typealias Value = Int
        var name: String {
            "value"
        }
        struct Property: Decodable, Sendable {
            var value: Int
            enum CodingKeys: CodingKey {
                case value
                var stringValue: String {
                    "\(Schema.tableName)_value"
                }
            }
        }
    }

    /// => value: Int
    static let value = __value()
}

enum TestTypes {
    /// => Int
    typealias Value = Test.__value.Value
}

extension Test: SchemaProtocol {
}
"""#,
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
expandedSource: #"""
public struct Test {
    public var fooBar: Int?

    public static let all = AllPropertyExpression<Test, Test>()

    public struct __fooBar: TypedSQLColumn, PropertySQLExpression {
        public typealias Schema = Test
        public typealias Value = Int?
        public var name: String {
            "fooBar"
        }
        public struct Property: Decodable, Sendable {
            public var fooBar: Int?
            public enum CodingKeys: CodingKey {
                case fooBar
                public var stringValue: String {
                    "\(Schema.tableName)_fooBar"
                }
            }
        }
    }

    /// => fooBar: Int?
    public static let fooBar = __fooBar()
}

public enum TestTypes {
    /// => Int?
    public typealias FooBar = Test.__fooBar.Value
}

extension Test: SchemaProtocol {
}
"""#,
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

    static let all = AllPropertyExpression<Test, Test>()
}

enum TestTypes {
}

extension Test: SchemaProtocol {
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
expandedSource: #"""
struct Test {
    var wrapper = ""

    static let all = AllPropertyExpression<Test, Test>()
}

enum TestTypes {
}

extension Test: SchemaProtocol {
}
"""#,
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
expandedSource: #"""
struct Test {
    var `class`: Class
    var `struct`: Int

    static let all = AllPropertyExpression<Test, Test>()

    struct __class: TypedSQLColumn, PropertySQLExpression {
        typealias Schema = Test
        typealias Value = Class
        var name: String {
            "class"
        }
        struct Property: Decodable, Sendable {
            var `class`: Class
            enum CodingKeys: CodingKey {
                case `class`
                var stringValue: String {
                    "\(Schema.tableName)_class"
                }
            }
        }
    }

    /// => `class`: Class
    static let `class` = __class()

    struct __struct: TypedSQLColumn, PropertySQLExpression {
        typealias Schema = Test
        typealias Value = Int
        var name: String {
            "struct"
        }
        struct Property: Decodable, Sendable {
            var `struct`: Int
            enum CodingKeys: CodingKey {
                case `struct`
                var stringValue: String {
                    "\(Schema.tableName)_struct"
                }
            }
        }
    }

    /// => `struct`: Int
    static let `struct` = __struct()
}

enum TestTypes {
    /// => Class
    typealias Class = Test.__class.Value
    /// => Int
    typealias Struct = Test.__struct.Value
}

extension Test: SchemaProtocol {
}
"""#,
macros: allMacro
        )
    }

    func testSchemaMacroIDProperty() throws {
        assertMacroExpansion(
"""
@Schema
struct Test {
    var id: UUID
}
""",
expandedSource: #"""
struct Test {
    var id: UUID

    static let all = AllPropertyExpression<Test, Test>()

    struct __id: TypedSQLColumn, PropertySQLExpression {
        typealias Schema = Test
        typealias Value = UUID
        var name: String {
            "id"
        }
        struct Property: Decodable, Sendable {
            var id: UUID
            enum CodingKeys: CodingKey {
                case id
                var stringValue: String {
                    "\(Schema.tableName)_id"
                }
            }
        }
    }

    /// => id: UUID
    static let id = __id()
}

enum TestTypes {
    /// => UUID
    typealias Id = Test.__id.Value
}

extension Test: IDSchemaProtocol, SchemaProtocol {
}
"""#,
macros: schemaMacro
        )
    }

    func testSchemaMacroManualConformance() throws {
        assertMacroExpansion(
"""
@Schema
struct Test: SchemaProtocol {
    var value: Int
}
""",
expandedSource: #"""
struct Test: SchemaProtocol {
    var value: Int

    static let all = AllPropertyExpression<Test, Test>()

    struct __value: TypedSQLColumn, PropertySQLExpression {
        typealias Schema = Test
        typealias Value = Int
        var name: String {
            "value"
        }
        struct Property: Decodable, Sendable {
            var value: Int
            enum CodingKeys: CodingKey {
                case value
                var stringValue: String {
                    "\(Schema.tableName)_value"
                }
            }
        }
    }

    /// => value: Int
    static let value = __value()
}

enum TestTypes {
    /// => Int
    typealias Value = Test.__value.Value
}
"""#,
macros: allMacro
        )
    }
}
#endif
