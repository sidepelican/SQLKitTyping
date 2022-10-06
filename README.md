# SQLKitTyping

Add slightly type safe interface for SQLKit.

# Install

```swift
.package(url: "https://github.com/sidepelican/SQLKitTyping.git", from: "..."),
```

# Usage

Define table schema

```swift
enum School: IDSchemaProtocol {
    static var tableName: String { "schools" }

    static let id = Column<SchoolID>("id")
    static let name = Column<String>("name")
}
```

Define entity type with Schema.
(The basic mechanism is based on Codable, just add thin propertyWrapper.)

```swift
struct SchoolAll: Identifiable, Codable {
    @TypeOf(School.id) var id // propagate column type
    @TypeOf(School.name) var name

    init(id: ID,
         name: String) {
        self.id = id
        self.name = name
    }
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
enum Student: IDSchemaProtocol {
    static var tableName: String { "students" }

    static let id = Column<StudentID>("id")
    static let name = Column<String>("name")
    static let age = Column<Int?>("age")
}

enum SchoolStudentRelation: RelationSchemaProtocol {
    static var tableName: String { "schools_students" }

    static let schoolID = Column<SchoolID>("schoolID")
    static let studentID = Column<StudentID>("studentID")

    static var relation: PivotJoinRelation<Self, SchoolID, StudentID> {
        .init(from: schoolID, to: studentID)
    }
}

struct SchoolWithStudents: Decodable, Identifiable {
    @TypeOf(School.id) var id
    @TypeOf(School.name) var name
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
