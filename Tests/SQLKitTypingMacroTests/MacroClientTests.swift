import XCTest
import SQLKitTyping

@Schema
public enum TestTable: SchemaProtocol {
    public static var tableName: String { "tests" }

    fileprivate var foo: Int
    var bar: String
}

fileprivate struct S {
    @TypeOf(TestTable.foo) var foo
    @TypeOf(TestTable.bar) var bar
}

enum Foo {
    @EraseProperty
    var enumProperty: Int
}
