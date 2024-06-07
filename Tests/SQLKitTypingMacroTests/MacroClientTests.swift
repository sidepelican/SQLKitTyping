import XCTest
import SQLKitTyping

@Schema
fileprivate enum TestTable: SchemaProtocol {
    static var tableName: String { "tests" }

    var foo: Int
    var bar: String
}

fileprivate struct S {
    var foo: TestTable.Foo
    var bar: TestTable.Bar
}

enum Foo {
    @EraseProperty
    var enumProperty: Int
}
