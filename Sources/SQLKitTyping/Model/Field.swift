@propertyWrapper public struct Field<Schema: SchemaProtocol, Value>: Decodable, CustomStringConvertible where Value: Decodable {
    public init(column: TypedSQLColumn<Schema, Value>) {
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

    public init(from decoder: Decoder) throws {
        let s = try decoder.singleValueContainer()
        wrappedValue = try s.decode(Value.self)
    }

    public var description: String {
        if let _wrappedValue = _wrappedValue {
            return String(describing: _wrappedValue)
        } else {
            return "uninitialized"
        }
    }
}

extension Field: Encodable where Value: Encodable {
    public func encode(to encoder: Encoder) throws {
        var s = encoder.singleValueContainer()
        try s.encode(wrappedValue)
    }
}

@propertyWrapper public struct OptionalField<Schema: SchemaProtocol, Value>: Decodable, CustomStringConvertible where Value: Decodable {
    public init(column: KeyPath<Schema, TypedSQLColumn<Schema, Value>>) {
    }

    public init(wrappedValue: Value?) {
        self.wrappedValue = wrappedValue
    }

    public var wrappedValue: Value?

    public init(from decoder: Decoder) throws {
        let s = try decoder.singleValueContainer()
        if s.decodeNil() {
            wrappedValue = nil
        } else {
            wrappedValue = try s.decode(Value.self)
        }
    }

    public var description: String {
        if let wrappedValue = wrappedValue {
            return String(describing: wrappedValue)
        } else {
            return "nil"
        }
    }
}

extension OptionalField: Encodable where Value: Encodable {
    public func encode(to encoder: Encoder) throws {
        var s = encoder.singleValueContainer()
        if let wrappedValue = wrappedValue {
            try s.encode(wrappedValue)
        } else {
            try s.encodeNil()
        }
    }
}
