fileprivate func intersectionDecode<each V: Decodable>(
    _ container: some SingleValueDecodingContainer
) throws -> (repeat each V) {
    return try (repeat container.decode((each V).self))
}

/*
for i in 2...12 {
    let e = """
@dynamicMemberLookup
public struct Intersection\(i)<
    \((0..<i).map({ "C\($0): Decodable" }).joined(separator: ", "))
>: Decodable {
    public typealias Values = (\((0..<i).map({ "C\($0)" }).joined(separator: ", ")))
    public var values: Values
    public init(_ values: Values) {
        self.values = values
    }

\((0..<i).map({ """
    @inlinable
    public subscript<T>(dynamicMember keyPath: KeyPath<C\($0), T>) -> T {
        values.\($0)[keyPath: keyPath]
    }
""" }).joined(separator: "\n\n"))

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.values = try intersectionDecode(container)
    }
}

"""
    print(e)
}
*/

@dynamicMemberLookup
public struct Intersection2<
    C0: Decodable, C1: Decodable
>: Decodable {
    public typealias Values = (C0, C1)
    public var values: Values
    public init(_ values: Values) {
        self.values = values
    }

    @inlinable
    public subscript<T>(dynamicMember keyPath: KeyPath<C0, T>) -> T {
        values.0[keyPath: keyPath]
    }

    @inlinable
    public subscript<T>(dynamicMember keyPath: KeyPath<C1, T>) -> T {
        values.1[keyPath: keyPath]
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.values = try intersectionDecode(container)
    }
}

@dynamicMemberLookup
public struct Intersection3<
    C0: Decodable, C1: Decodable, C2: Decodable
>: Decodable {
    public typealias Values = (C0, C1, C2)
    public var values: Values
    public init(_ values: Values) {
        self.values = values
    }

    @inlinable
    public subscript<T>(dynamicMember keyPath: KeyPath<C0, T>) -> T {
        values.0[keyPath: keyPath]
    }

    @inlinable
    public subscript<T>(dynamicMember keyPath: KeyPath<C1, T>) -> T {
        values.1[keyPath: keyPath]
    }

    @inlinable
    public subscript<T>(dynamicMember keyPath: KeyPath<C2, T>) -> T {
        values.2[keyPath: keyPath]
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.values = try intersectionDecode(container)
    }
}

@dynamicMemberLookup
public struct Intersection4<
    C0: Decodable, C1: Decodable, C2: Decodable, C3: Decodable
>: Decodable {
    public typealias Values = (C0, C1, C2, C3)
    public var values: Values
    public init(_ values: Values) {
        self.values = values
    }

    @inlinable
    public subscript<T>(dynamicMember keyPath: KeyPath<C0, T>) -> T {
        values.0[keyPath: keyPath]
    }

    @inlinable
    public subscript<T>(dynamicMember keyPath: KeyPath<C1, T>) -> T {
        values.1[keyPath: keyPath]
    }

    @inlinable
    public subscript<T>(dynamicMember keyPath: KeyPath<C2, T>) -> T {
        values.2[keyPath: keyPath]
    }

    @inlinable
    public subscript<T>(dynamicMember keyPath: KeyPath<C3, T>) -> T {
        values.3[keyPath: keyPath]
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.values = try intersectionDecode(container)
    }
}

@dynamicMemberLookup
public struct Intersection5<
    C0: Decodable, C1: Decodable, C2: Decodable, C3: Decodable, C4: Decodable
>: Decodable {
    public typealias Values = (C0, C1, C2, C3, C4)
    public var values: Values
    public init(_ values: Values) {
        self.values = values
    }

    @inlinable
    public subscript<T>(dynamicMember keyPath: KeyPath<C0, T>) -> T {
        values.0[keyPath: keyPath]
    }

    @inlinable
    public subscript<T>(dynamicMember keyPath: KeyPath<C1, T>) -> T {
        values.1[keyPath: keyPath]
    }

    @inlinable
    public subscript<T>(dynamicMember keyPath: KeyPath<C2, T>) -> T {
        values.2[keyPath: keyPath]
    }

    @inlinable
    public subscript<T>(dynamicMember keyPath: KeyPath<C3, T>) -> T {
        values.3[keyPath: keyPath]
    }

    @inlinable
    public subscript<T>(dynamicMember keyPath: KeyPath<C4, T>) -> T {
        values.4[keyPath: keyPath]
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.values = try intersectionDecode(container)
    }
}

@dynamicMemberLookup
public struct Intersection6<
    C0: Decodable, C1: Decodable, C2: Decodable, C3: Decodable, C4: Decodable, C5: Decodable
>: Decodable {
    public typealias Values = (C0, C1, C2, C3, C4, C5)
    public var values: Values
    public init(_ values: Values) {
        self.values = values
    }

    @inlinable
    public subscript<T>(dynamicMember keyPath: KeyPath<C0, T>) -> T {
        values.0[keyPath: keyPath]
    }

    @inlinable
    public subscript<T>(dynamicMember keyPath: KeyPath<C1, T>) -> T {
        values.1[keyPath: keyPath]
    }

    @inlinable
    public subscript<T>(dynamicMember keyPath: KeyPath<C2, T>) -> T {
        values.2[keyPath: keyPath]
    }

    @inlinable
    public subscript<T>(dynamicMember keyPath: KeyPath<C3, T>) -> T {
        values.3[keyPath: keyPath]
    }

    @inlinable
    public subscript<T>(dynamicMember keyPath: KeyPath<C4, T>) -> T {
        values.4[keyPath: keyPath]
    }

    @inlinable
    public subscript<T>(dynamicMember keyPath: KeyPath<C5, T>) -> T {
        values.5[keyPath: keyPath]
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.values = try intersectionDecode(container)
    }
}

@dynamicMemberLookup
public struct Intersection7<
    C0: Decodable, C1: Decodable, C2: Decodable, C3: Decodable, C4: Decodable, C5: Decodable, C6: Decodable
>: Decodable {
    public typealias Values = (C0, C1, C2, C3, C4, C5, C6)
    public var values: Values
    public init(_ values: Values) {
        self.values = values
    }

    @inlinable
    public subscript<T>(dynamicMember keyPath: KeyPath<C0, T>) -> T {
        values.0[keyPath: keyPath]
    }

    @inlinable
    public subscript<T>(dynamicMember keyPath: KeyPath<C1, T>) -> T {
        values.1[keyPath: keyPath]
    }

    @inlinable
    public subscript<T>(dynamicMember keyPath: KeyPath<C2, T>) -> T {
        values.2[keyPath: keyPath]
    }

    @inlinable
    public subscript<T>(dynamicMember keyPath: KeyPath<C3, T>) -> T {
        values.3[keyPath: keyPath]
    }

    @inlinable
    public subscript<T>(dynamicMember keyPath: KeyPath<C4, T>) -> T {
        values.4[keyPath: keyPath]
    }

    @inlinable
    public subscript<T>(dynamicMember keyPath: KeyPath<C5, T>) -> T {
        values.5[keyPath: keyPath]
    }

    @inlinable
    public subscript<T>(dynamicMember keyPath: KeyPath<C6, T>) -> T {
        values.6[keyPath: keyPath]
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.values = try intersectionDecode(container)
    }
}

@dynamicMemberLookup
public struct Intersection8<
    C0: Decodable, C1: Decodable, C2: Decodable, C3: Decodable, C4: Decodable, C5: Decodable, C6: Decodable, C7: Decodable
>: Decodable {
    public typealias Values = (C0, C1, C2, C3, C4, C5, C6, C7)
    public var values: Values
    public init(_ values: Values) {
        self.values = values
    }

    @inlinable
    public subscript<T>(dynamicMember keyPath: KeyPath<C0, T>) -> T {
        values.0[keyPath: keyPath]
    }

    @inlinable
    public subscript<T>(dynamicMember keyPath: KeyPath<C1, T>) -> T {
        values.1[keyPath: keyPath]
    }

    @inlinable
    public subscript<T>(dynamicMember keyPath: KeyPath<C2, T>) -> T {
        values.2[keyPath: keyPath]
    }

    @inlinable
    public subscript<T>(dynamicMember keyPath: KeyPath<C3, T>) -> T {
        values.3[keyPath: keyPath]
    }

    @inlinable
    public subscript<T>(dynamicMember keyPath: KeyPath<C4, T>) -> T {
        values.4[keyPath: keyPath]
    }

    @inlinable
    public subscript<T>(dynamicMember keyPath: KeyPath<C5, T>) -> T {
        values.5[keyPath: keyPath]
    }

    @inlinable
    public subscript<T>(dynamicMember keyPath: KeyPath<C6, T>) -> T {
        values.6[keyPath: keyPath]
    }

    @inlinable
    public subscript<T>(dynamicMember keyPath: KeyPath<C7, T>) -> T {
        values.7[keyPath: keyPath]
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.values = try intersectionDecode(container)
    }
}

@dynamicMemberLookup
public struct Intersection9<
    C0: Decodable, C1: Decodable, C2: Decodable, C3: Decodable, C4: Decodable, C5: Decodable, C6: Decodable, C7: Decodable, C8: Decodable
>: Decodable {
    public typealias Values = (C0, C1, C2, C3, C4, C5, C6, C7, C8)
    public var values: Values
    public init(_ values: Values) {
        self.values = values
    }

    @inlinable
    public subscript<T>(dynamicMember keyPath: KeyPath<C0, T>) -> T {
        values.0[keyPath: keyPath]
    }

    @inlinable
    public subscript<T>(dynamicMember keyPath: KeyPath<C1, T>) -> T {
        values.1[keyPath: keyPath]
    }

    @inlinable
    public subscript<T>(dynamicMember keyPath: KeyPath<C2, T>) -> T {
        values.2[keyPath: keyPath]
    }

    @inlinable
    public subscript<T>(dynamicMember keyPath: KeyPath<C3, T>) -> T {
        values.3[keyPath: keyPath]
    }

    @inlinable
    public subscript<T>(dynamicMember keyPath: KeyPath<C4, T>) -> T {
        values.4[keyPath: keyPath]
    }

    @inlinable
    public subscript<T>(dynamicMember keyPath: KeyPath<C5, T>) -> T {
        values.5[keyPath: keyPath]
    }

    @inlinable
    public subscript<T>(dynamicMember keyPath: KeyPath<C6, T>) -> T {
        values.6[keyPath: keyPath]
    }

    @inlinable
    public subscript<T>(dynamicMember keyPath: KeyPath<C7, T>) -> T {
        values.7[keyPath: keyPath]
    }

    @inlinable
    public subscript<T>(dynamicMember keyPath: KeyPath<C8, T>) -> T {
        values.8[keyPath: keyPath]
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.values = try intersectionDecode(container)
    }
}

@dynamicMemberLookup
public struct Intersection10<
    C0: Decodable, C1: Decodable, C2: Decodable, C3: Decodable, C4: Decodable, C5: Decodable, C6: Decodable, C7: Decodable, C8: Decodable, C9: Decodable
>: Decodable {
    public typealias Values = (C0, C1, C2, C3, C4, C5, C6, C7, C8, C9)
    public var values: Values
    public init(_ values: Values) {
        self.values = values
    }

    @inlinable
    public subscript<T>(dynamicMember keyPath: KeyPath<C0, T>) -> T {
        values.0[keyPath: keyPath]
    }

    @inlinable
    public subscript<T>(dynamicMember keyPath: KeyPath<C1, T>) -> T {
        values.1[keyPath: keyPath]
    }

    @inlinable
    public subscript<T>(dynamicMember keyPath: KeyPath<C2, T>) -> T {
        values.2[keyPath: keyPath]
    }

    @inlinable
    public subscript<T>(dynamicMember keyPath: KeyPath<C3, T>) -> T {
        values.3[keyPath: keyPath]
    }

    @inlinable
    public subscript<T>(dynamicMember keyPath: KeyPath<C4, T>) -> T {
        values.4[keyPath: keyPath]
    }

    @inlinable
    public subscript<T>(dynamicMember keyPath: KeyPath<C5, T>) -> T {
        values.5[keyPath: keyPath]
    }

    @inlinable
    public subscript<T>(dynamicMember keyPath: KeyPath<C6, T>) -> T {
        values.6[keyPath: keyPath]
    }

    @inlinable
    public subscript<T>(dynamicMember keyPath: KeyPath<C7, T>) -> T {
        values.7[keyPath: keyPath]
    }

    @inlinable
    public subscript<T>(dynamicMember keyPath: KeyPath<C8, T>) -> T {
        values.8[keyPath: keyPath]
    }

    @inlinable
    public subscript<T>(dynamicMember keyPath: KeyPath<C9, T>) -> T {
        values.9[keyPath: keyPath]
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.values = try intersectionDecode(container)
    }
}

@dynamicMemberLookup
public struct Intersection11<
    C0: Decodable, C1: Decodable, C2: Decodable, C3: Decodable, C4: Decodable, C5: Decodable, C6: Decodable, C7: Decodable, C8: Decodable, C9: Decodable, C10: Decodable
>: Decodable {
    public typealias Values = (C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, C10)
    public var values: Values
    public init(_ values: Values) {
        self.values = values
    }

    @inlinable
    public subscript<T>(dynamicMember keyPath: KeyPath<C0, T>) -> T {
        values.0[keyPath: keyPath]
    }

    @inlinable
    public subscript<T>(dynamicMember keyPath: KeyPath<C1, T>) -> T {
        values.1[keyPath: keyPath]
    }

    @inlinable
    public subscript<T>(dynamicMember keyPath: KeyPath<C2, T>) -> T {
        values.2[keyPath: keyPath]
    }

    @inlinable
    public subscript<T>(dynamicMember keyPath: KeyPath<C3, T>) -> T {
        values.3[keyPath: keyPath]
    }

    @inlinable
    public subscript<T>(dynamicMember keyPath: KeyPath<C4, T>) -> T {
        values.4[keyPath: keyPath]
    }

    @inlinable
    public subscript<T>(dynamicMember keyPath: KeyPath<C5, T>) -> T {
        values.5[keyPath: keyPath]
    }

    @inlinable
    public subscript<T>(dynamicMember keyPath: KeyPath<C6, T>) -> T {
        values.6[keyPath: keyPath]
    }

    @inlinable
    public subscript<T>(dynamicMember keyPath: KeyPath<C7, T>) -> T {
        values.7[keyPath: keyPath]
    }

    @inlinable
    public subscript<T>(dynamicMember keyPath: KeyPath<C8, T>) -> T {
        values.8[keyPath: keyPath]
    }

    @inlinable
    public subscript<T>(dynamicMember keyPath: KeyPath<C9, T>) -> T {
        values.9[keyPath: keyPath]
    }

    @inlinable
    public subscript<T>(dynamicMember keyPath: KeyPath<C10, T>) -> T {
        values.10[keyPath: keyPath]
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.values = try intersectionDecode(container)
    }
}

@dynamicMemberLookup
public struct Intersection12<
    C0: Decodable, C1: Decodable, C2: Decodable, C3: Decodable, C4: Decodable, C5: Decodable, C6: Decodable, C7: Decodable, C8: Decodable, C9: Decodable, C10: Decodable, C11: Decodable
>: Decodable {
    public typealias Values = (C0, C1, C2, C3, C4, C5, C6, C7, C8, C9, C10, C11)
    public var values: Values
    public init(_ values: Values) {
        self.values = values
    }

    @inlinable
    public subscript<T>(dynamicMember keyPath: KeyPath<C0, T>) -> T {
        values.0[keyPath: keyPath]
    }

    @inlinable
    public subscript<T>(dynamicMember keyPath: KeyPath<C1, T>) -> T {
        values.1[keyPath: keyPath]
    }

    @inlinable
    public subscript<T>(dynamicMember keyPath: KeyPath<C2, T>) -> T {
        values.2[keyPath: keyPath]
    }

    @inlinable
    public subscript<T>(dynamicMember keyPath: KeyPath<C3, T>) -> T {
        values.3[keyPath: keyPath]
    }

    @inlinable
    public subscript<T>(dynamicMember keyPath: KeyPath<C4, T>) -> T {
        values.4[keyPath: keyPath]
    }

    @inlinable
    public subscript<T>(dynamicMember keyPath: KeyPath<C5, T>) -> T {
        values.5[keyPath: keyPath]
    }

    @inlinable
    public subscript<T>(dynamicMember keyPath: KeyPath<C6, T>) -> T {
        values.6[keyPath: keyPath]
    }

    @inlinable
    public subscript<T>(dynamicMember keyPath: KeyPath<C7, T>) -> T {
        values.7[keyPath: keyPath]
    }

    @inlinable
    public subscript<T>(dynamicMember keyPath: KeyPath<C8, T>) -> T {
        values.8[keyPath: keyPath]
    }

    @inlinable
    public subscript<T>(dynamicMember keyPath: KeyPath<C9, T>) -> T {
        values.9[keyPath: keyPath]
    }

    @inlinable
    public subscript<T>(dynamicMember keyPath: KeyPath<C10, T>) -> T {
        values.10[keyPath: keyPath]
    }

    @inlinable
    public subscript<T>(dynamicMember keyPath: KeyPath<C11, T>) -> T {
        values.11[keyPath: keyPath]
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.values = try intersectionDecode(container)
    }
}
