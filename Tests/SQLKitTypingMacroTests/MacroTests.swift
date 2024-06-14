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
    var value: Int {
        @available(*, unavailable)
        get {
            fatalError()
        }
    }

    struct __allProperty: Decodable {
        var value: Int
    }

    static let all = AllPropertyExpression<Test, __allProperty>()

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

    /// => value: Int
    static let value = __value()
}

enum TestTypes {
    typealias All = Test.__allProperty
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
    @EraseProperty
    public var fooBar: Int?

    public struct __allProperty: Decodable {
        public var fooBar: Int?
    }

    public static let all = AllPropertyExpression<Test, __allProperty>()

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

    /// => fooBar: Int?
    public static let fooBar = __fooBar()
}

public enum TestTypes {
    public typealias All = Test.__allProperty
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

    struct __allProperty: Decodable {
    }

    static let all = AllPropertyExpression<Test, __allProperty>()
}

enum TestTypes {
    typealias All = Test.__allProperty
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

    struct __allProperty: Decodable {
    }

    static let all = AllPropertyExpression<Test, __allProperty>()
}

enum TestTypes {
    typealias All = Test.__allProperty
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
    var `struct`: Int {
        @available(*, unavailable)
        get {
            fatalError()
        }
    }

    struct __allProperty: Decodable {
        var `class`: Class
        var `struct`: Int
    }

    static let all = AllPropertyExpression<Test, __allProperty>()

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

    /// => `class`: Class
    static let `class` = __class()

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

    /// => `struct`: Int
    static let `struct` = __struct()
}

enum TestTypes {
    typealias All = Test.__allProperty
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
    @EraseProperty
    var value: Int

    struct __allProperty: Decodable {
        var value: Int
    }

    static let all = AllPropertyExpression<Test, __allProperty>()

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

    /// => value: Int
    static let value = __value()
}

enum TestTypes {
    typealias All = Test.__allProperty
}
"""#,
macros: schemaMacro
        )
    }
}
#endif
