@propertyWrapper public struct TypeOf<Schema: SchemaProtocol, Value>: CustomStringConvertible {
    public init(_ column: TypedSQLColumn<Schema, Value>) {
    }

    public init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }

    private var _wrappedValue: Value?
    public var wrappedValue: Value {
        get {
            precondition(_wrappedValue != nil, "value not initialized")
            return _wrappedValue.unsafelyUnwrapped
        }
        set {
            _wrappedValue = newValue
        }
    }

    public var description: String {
        if let _wrappedValue = _wrappedValue {
            return String(describing: _wrappedValue)
        } else {
            return "uninitialized"
        }
    }
}

extension TypeOf: Decodable where Value: Decodable {
    public init(from decoder: Decoder) throws {
        let s = try decoder.singleValueContainer()
        wrappedValue = try s.decode(Value.self)
    }
}

extension TypeOf: Encodable where Value: Encodable {
    public func encode(to encoder: Encoder) throws {
        var s = encoder.singleValueContainer()
        try s.encode(wrappedValue)
    }
}

extension TypeOf: Equatable where Value: Equatable {}
extension TypeOf: Hashable where Value: Hashable {}
extension TypeOf: Sendable where Value: Sendable {}

@propertyWrapper public struct OptionalTypeOf<Schema: SchemaProtocol, Value>: CustomStringConvertible {
    public init(_ column: TypedSQLColumn<Schema, Value>) {
    }

    public init(wrappedValue: Value?) {
        self.wrappedValue = wrappedValue
    }

    public var wrappedValue: Value?

    public var description: String {
        if let wrappedValue = wrappedValue {
            return String(describing: wrappedValue)
        } else {
            return "nil"
        }
    }
}

extension OptionalTypeOf: Decodable where Value: Decodable {
    public init(from decoder: Decoder) throws {
        let s = try decoder.singleValueContainer()
        if s.decodeNil() {
            wrappedValue = nil
        } else {
            wrappedValue = try s.decode(Value.self)
        }
    }
}

extension OptionalTypeOf: Encodable where Value: Encodable {
    public func encode(to encoder: Encoder) throws {
        var s = encoder.singleValueContainer()
        if let wrappedValue = wrappedValue {
            try s.encode(wrappedValue)
        } else {
            try s.encodeNil()
        }
    }
}

extension OptionalTypeOf: Equatable where Value: Equatable {}
extension OptionalTypeOf: Hashable where Value: Hashable {}
extension OptionalTypeOf: Sendable where Value: Sendable {}
