import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(SQLKitTypingMacros)
import SQLKitTypingMacros

private let allMacro: [String: any Macro.Type] = [
    "Schema": Schema.self,
    "Column": Column.self,
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
    var value: Int {
        @available(*, unavailable)
        get {
            fatalError()
        }
    }

    /// => Int
    typealias Value = Test_types.__value.Value

    /// => value: Int
    static let value = Test_types.__value()

    typealias All = Test_types.__allProperty

    static let all = AllPropertyExpression<Test, Test_types.__allProperty>()
}

enum Test_types {
    struct __allProperty: Decodable {
        var value: Int
    }
    struct __value: TypedSQLColumn, PropertySQLExpression {
        typealias Schema = Test
        typealias Value = Int

        var name: String {
            "value"
        }

        struct Property: Decodable {
            var value: Int
            enum CodingKeys: CodingKey {
                case value
                var stringValue: String {
                    "\(Schema.tableName)_value"
                }
            }
        }
    }
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
    @EraseProperty @Column(namespace: "Test_types")
    public var fooBar: Int?

    public typealias All = Test_types.__allProperty

    public static let all = AllPropertyExpression<Test, Test_types.__allProperty>()
}

public enum Test_types {
    public struct __allProperty: Decodable {
        public var fooBar: Int?
    }
    public struct __fooBar: TypedSQLColumn, PropertySQLExpression {
        public typealias Schema = Test
        public typealias Value = Int?

        public var name: String {
            "fooBar"
        }

        public struct Property: Decodable {
            public var fooBar: Int?
            public enum CodingKeys: CodingKey {
                case fooBar
                public var stringValue: String {
                    "\(Schema.tableName)_fooBar"
                }
            }
        }
    }
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

    typealias All = Test_types.__allProperty

    static let all = AllPropertyExpression<Test, Test_types.__allProperty>()
}

enum Test_types {
    struct __allProperty: Decodable {
    }
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

    typealias All = Test_types.__allProperty

    static let all = AllPropertyExpression<Test, Test_types.__allProperty>()
}

enum Test_types {
    struct __allProperty: Decodable {
    }
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
    var `class`: Class {
        @available(*, unavailable)
        get {
            fatalError()
        }
    }

    /// => Class
    typealias Class = Test_types.__class.Value

    /// => `class`: Class
    static let `class` = Test_types.__class()
    var `struct`: Int {
        @available(*, unavailable)
        get {
            fatalError()
        }
    }

    /// => Int
    typealias Struct = Test_types.__struct.Value

    /// => `struct`: Int
    static let `struct` = Test_types.__struct()

    typealias All = Test_types.__allProperty

    static let all = AllPropertyExpression<Test, Test_types.__allProperty>()
}

enum Test_types {
    struct __allProperty: Decodable {
        var `class`: Class
        var `struct`: Int
    }
    struct __class: TypedSQLColumn, PropertySQLExpression {
        typealias Schema = Test
        typealias Value = Class

        var name: String {
            "class"
        }

        struct Property: Decodable {
            var `class`: Class
            enum CodingKeys: CodingKey {
                case `class`
                var stringValue: String {
                    "\(Schema.tableName)_class"
                }
            }
        }
    }
    struct __struct: TypedSQLColumn, PropertySQLExpression {
        typealias Schema = Test
        typealias Value = Int

        var name: String {
            "struct"
        }

        struct Property: Decodable {
            var `struct`: Int
            enum CodingKeys: CodingKey {
                case `struct`
                var stringValue: String {
                    "\(Schema.tableName)_struct"
                }
            }
        }
    }
}
"""#,
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
expandedSource: #"""
enum Test {
    @EraseProperty @Column(namespace: "Test_types")
    var value: Int

    typealias All = Test_types.__allProperty

    static let all = AllPropertyExpression<Test, Test_types.__allProperty>()
}

enum Test_types {
    struct __allProperty: Decodable {
        var value: Int
    }
    struct __value: TypedSQLColumn, PropertySQLExpression {
        typealias Schema = Test
        typealias Value = Int

        var name: String {
            "value"
        }

        struct Property: Decodable {
            var value: Int
            enum CodingKeys: CodingKey {
                case value
                var stringValue: String {
                    "\(Schema.tableName)_value"
                }
            }
        }
    }
}
"""#,
macros: schemaMacro
        )
    }
}
#endif
