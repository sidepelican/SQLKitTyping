# SQLKitTyping

Add slightly type safe interface for SQLKit.

# Install

```swift
.package(url: "https://github.com/sidepelican/SQLKitTyping.git", from: "..."),
```

# Usage

Define table schema

```swift
@Schema
enum School: IDSchemaProtocol {
    static var tableName: String { "schools" }

    var id: SchoolID
    var name: String
}
```

Define entity type with Column Type.

```swift
struct SchoolAll: Identifiable, Codable {
    var id: School.Id // macro generates column types
    var name: School.Name
}
```

Query with type safe column

```swift
let id = SchoolID(...)
var rows = try await sql.select()
    .column(School.all)
    .from(School.self)
    .where(School.id, .equal , id) // Only 'SchoolID' type is allowed
    .all(decoding: StudentAll.self)
```

Eagerload children or slibling entities

```swift
@Schema
enum Student: IDSchemaProtocol {
    static var tableName: String { "students" }

    var id: StudentID
    var name: String
    var age: Int?
}

@Schema
enum SchoolStudentRelation: RelationSchemaProtocol {
    static var tableName: String { "schools_students" }

    var schoolID: SchoolID
    var studentID: StudentID

    static var relation: PivotJoinRelation<Self, SchoolID, StudentID> {
        .init(from: schoolID, to: studentID)
    }
}

struct SchoolWithStudents: Decodable, Identifiable {
    var id: School.Id
    var name: School.Name
    var students: [StudentAll] = []

    enum CodingKeys: String, CodingKey {
        case id
        case name
    }
}

var rows = try await sql.select()
    .column(School.all)
    .from(School.self)
    .all(decoding: SchoolWithStudents.self)
try await sql.eagerLoadAllColumns(into: &rows, keyPath: \.students,
                                  targetTable: Student.self,
                                  relationTable: SchoolStudentRelation.self)
XCTAssertEqual(Set(rows.map(\.students.count)), [4, 3, 0])

```
