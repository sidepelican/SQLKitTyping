import SQLKit

public struct SQLInterval: SQLExpression {
    public var second: Int?
    public var minute: Int?
    public var hour: Int?
    public var day: Int?
    public var month: Int?
    public var year: Int?

    public static func second(_ value: Int) -> SQLInterval {
        .init(second: value)
    }

    public static func minute(_ value: Int) -> SQLInterval {
        .init(minute: value)
    }

    public static func hour(_ value: Int) -> SQLInterval {
        .init(hour: value)
    }

    public static func day(_ value: Int) -> SQLInterval {
        .init(day: value)
    }

    public static func month(_ value: Int) -> SQLInterval {
        .init(month: value)
    }

    public static func year(_ value: Int) -> SQLInterval {
        .init(year: value)
    }

    public func serialize(to serializer: inout SQLSerializer) {
        var units: [String] = []
        if let year {
            units.append("\(year) year")
        }
        if let month {
            units.append("\(month) month")
        }
        if let day {
            units.append("\(day) day")
        }
        if let hour {
            units.append("\(hour) hour")
        }
        if let minute {
            units.append("\(minute) minute")
        }
        if let second {
            units.append("\(second) second")
        }

        serializer.statement {
            $0.append("interval")
            $0.append(SQLLiteral.string(units.joined(separator: " ")))
        }
    }
}
