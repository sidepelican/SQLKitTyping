import XCTest
import SQLKitTyping

@Schema
fileprivate enum Test: SchemaProtocol {
    static var tableName: String { "tests" }

    var foo: Int
    var bar: String
}

fileprivate struct S {
    var foo: Test.Foo
    var bar: Test.Bar
}

enum Foo {
    @EraseProperty
    var enumProperty: Int
}
