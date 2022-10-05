struct GenericID<Tag, RawValue>: RawRepresentable, Sendable, Hashable, Codable, CustomStringConvertible
where
    RawValue: Sendable & Hashable & Codable & CustomStringConvertible
{
    var rawValue: RawValue
    var id: RawValue { rawValue }

    init(_ id: RawValue) {
        self.init(rawValue: id)
    }

    init(rawValue: RawValue) {
        self.rawValue = rawValue
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        rawValue = try container.decode(RawValue.self)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }

    var description: String {
        rawValue.description
    }
}
