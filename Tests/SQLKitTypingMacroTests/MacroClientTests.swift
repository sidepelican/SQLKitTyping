import XCTest
import SQLKitTyping

@Schema
fileprivate struct Test: SchemaProtocol {
    static var tableName: String { "tests" }

    var foo: Int
    var bar: String
}
