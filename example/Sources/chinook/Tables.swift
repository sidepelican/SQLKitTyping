import SQLKitTyping
import Foundation

@Schema
struct TrackTable: SchemaProtocol {
    static var tableName: String { "tracks" }

    var TrackId: Int
    var Name: String
    var AlbumId: Int?
    var MediaTypeId: Int
    var GenreId: Int?
    var Composer: String?
    var Milliseconds: Int
    var Bytes: Int?
    var UnitPrice: Double
}

@Schema
struct AlbumTable: SchemaProtocol {
    static var tableName: String { "albums" }

    var AlbumId: Int
    var Title: String
    var ArtistId: Int
}

@Schema
struct ArtistTable: SchemaProtocol {
    static var tableName: String { "artists" }

    var ArtistId: Int
    var Name: String
}

@Schema
struct EmployeeTable: SchemaProtocol {
    static var tableName: String { "employees" }

    var EmployeeId: Int
    var LastName: String
    var FirstName: String
    var Title: String?
    var ReportsTo: Int?
    var BirthDate: Date?
    var HireDate: Date?
    var Address: String?
    var City: String?
    var State: String?
    var Country: String?
    var PostalCode: String?
    var Phone: String?
    var Fax: String?
    var Email: String?
}
