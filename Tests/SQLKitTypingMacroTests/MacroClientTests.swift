import XCTest
import SQLKitTyping

@Schema
public enum TestTable: SchemaProtocol {
    public static var tableName: String { "tests" }

    fileprivate var foo: Int
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
