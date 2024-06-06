import Foundation
import SQLKit

public struct SQLLikePattern: SQLExpression {
    public init(_ string: String, method: Contains = .anywhere) {
        self.string = string
        self.method = method
    }

    public init(_ string: some RawRepresentable<String>, method: Contains = .anywhere) {
        self.string = string.rawValue
        self.method = method
    }

    public init(_ string: some CustomStringConvertible, method: Contains = .anywhere) {
        self.string = string.description
        self.method = method
    }

    public enum Contains: Sendable {
        case prefix
        case suffix
        case anywhere
    }

    public var string: String
    public var method: Contains

    public func serialize(to serializer: inout SQLSerializer) {
        let safeString = string
            .replacingOccurrences(of: #"\"#, with: #"\\"#)
            .replacingOccurrences(of: "%", with: #"\%"#)
            .replacingOccurrences(of: "_", with: #"\_"#)
        let exp: String
        switch method {
        case .anywhere:
            exp = "%" + safeString + "%"
        case .prefix:
            exp = safeString + "%"
        case .suffix:
            exp = "%" + safeString
        }
        serializer.write(bind: exp)
    }
}
