import SQLKit

public struct NullableColumnExpression<Base: PropertySQLExpression>: PropertySQLExpression {
    @inlinable
    public init(base: Base) {
        self.base = base
    }

    struct NullableDecoder: Decoder {
        var parent: any Decoder

        var codingPath: [any CodingKey] {
            parent.codingPath
        }
        var userInfo: [CodingUserInfoKey : Any] {
            parent.userInfo
        }

        struct ValueNotFound: Error {}

        struct KeyedContainer<Key: CodingKey>: KeyedDecodingContainerProtocol {
            var parent: KeyedDecodingContainer<Key>
            var codingPath: [any CodingKey] { parent.codingPath }
            var allKeys: [Key] { parent.allKeys }

            func contains(_ key: Key) -> Bool {
                return parent.contains(key)
            }

            func decodeNil(forKey key: Key) throws -> Bool {
                return try parent.decodeNil(forKey: key)
            }

            func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T : Decodable {
                guard let value = try parent.decodeIfPresent(type, forKey: key) else {
                    throw ValueNotFound()
                }
                return value
            }

            func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
                return try parent.nestedContainer(keyedBy: type, forKey: key)
            }

            func nestedUnkeyedContainer(forKey key: Key) throws -> any UnkeyedDecodingContainer {
                return try parent.nestedUnkeyedContainer(forKey: key)
            }

            func superDecoder() throws -> any Decoder {
                return try parent.superDecoder()
            }

            func superDecoder(forKey key: Key) throws -> any Decoder {
                return try parent.superDecoder(forKey: key)
            }
        }

        func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
            return .init(KeyedContainer(parent: try parent.container(keyedBy: type)))
        }

        func unkeyedContainer() throws -> any UnkeyedDecodingContainer {
            return try parent.unkeyedContainer()
        }

        func singleValueContainer() throws -> any SingleValueDecodingContainer {
            return try parent.singleValueContainer()
        }
    }

    @dynamicMemberLookup
    public struct Property: Decodable {
        public var wrapped: Base.Property?

        public init(from decoder: any Decoder) throws {
            do {
                wrapped = try Base.Property(from: NullableDecoder(parent: decoder))
            } catch is NullableDecoder.ValueNotFound {
                wrapped = nil
            } catch let error as DecodingError {
                if case .valueNotFound = error {
                    wrapped = nil
                }
            }
        }

        @inlinable
        public subscript<T>(dynamicMember keyPath: KeyPath<Base.Property, T>) -> T? {
            wrapped?[keyPath: keyPath]
        }
    }

    @usableFromInline
    var base: Base

    public func serializeAsPropertySQLExpression(to serializer: inout SQLSerializer)  {
        base.serializeAsPropertySQLExpression(to: &serializer)
    }
}

extension PropertySQLExpression where Self: TypedSQLColumn {
    @inlinable
    public var nullable: NullableColumnExpression<Self> {
        NullableColumnExpression(base: self)
    }
}
