@propertyWrapper public struct ModelField<Schema: SchemaProtocol, Value>: Decodable where Value: Decodable {
    public init(column: KeyPath<Schema, TypedSQLColumn<Schema, Value>>) {
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
}

extension Model {
    public typealias Field<T> = ModelField<Schema, T> where T: Decodable
}

extension ModelField: Encodable where Value: Encodable {
    public func encode(to encoder: Encoder) throws {
        var s = encoder.singleValueContainer()
        try s.encode(wrappedValue)
    }
}

@propertyWrapper public struct OptionalField<Schema: SchemaProtocol, Value>: Decodable where Value: Decodable {
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
