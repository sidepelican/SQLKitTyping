import SQLKit

public struct SQLCurrentTimestamp: SQLExpression {
    public init() {
    }

    public func adding(_ interval: SQLInterval) -> some SQLExpression {
        SQLBinaryExpression(self, .add, interval)
    }

    public func subtracting(_ interval: SQLInterval) -> some SQLExpression {
        SQLBinaryExpression(self, .subtract, interval)
    }

    public func serialize(to serializer: inout SQLSerializer) {
        serializer.write("CURRENT_TIMESTAMP")
    }
}
