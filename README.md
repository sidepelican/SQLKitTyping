# SQLKitTyping

Add slightly type safe interface for SQLKit.

# Install

```swift
.package(url: "https://github.com/sidepelican/SQLKitTyping.git", from: "..."),
```

# Usage

Define table entity type and add `@Schema` macro.
(Please also add `tableName` property. `@Schema` macro adds `SchemaProtocol` and `tableName` is required by it.)

```swift
@Schema
struct School {
    static var tableName: String { "schools" }

    var id: SchoolID
    var name: String
}
```

`@Schema` macro provides static properties about column expression including its type.


```swift
School.id // some TypedSQLColumn<School, SchoolID>
School.name // some TypedSQLColumn<School, String>
```

Query with type safe column

```swift
func schools(schoolID: SchoolID, studentID: StudentID) async throws {
    var rows = try await sql.select()
        .column(School.all) // .all is also provided. This means '*'.
        .from(School.self)
        .where(School.id, .equal , schoolID) // Type safe!
        // .where(School.id, .equal , studentID) // Compile error!
        .all(decoding: School.self)
    ...
}
```

## Query individual columns

`sql.selectWithColumns` can query individual columns and take results rows with its column properties.

```swift
let row = try await sql.selectWithColumns {
        School.id
        School.name
    }
    .from(School.self)
    .where(School.id, .equal, schoolID)
    .first()
if let row {
    print(row.id) // SchoolID
    print(row.name) // String
}
```

Can be combined with other tables.

```swift
@Schema
struct Lesson {
    static var tableName: String { "lessons" }

    var id: LessonID
    var subject: String
    var schoolID: SchoolID
    var date: Date?
}

let rows = try await sql.selectWithColumns {
    Lesson.all
    School.name
}
    .from(Lesson.self)
    .join(School.self, on: Lesson.schoolID, .equal, School.id)
    .all()
if let row = rows.first {
    print(row.subject) // String
    print(row.date) // Date?
    print(row.name) // String
}
```

### Fine utilities

- `.nullable`
  If JOIN makes the column type nullable.

```swift
let rows = try await sql.selectWithColumns {
    Lesson.all
    School.name.nullable
}
    .from(Lesson.self)
    .join(School.self, method: SQLJoinMethod.left,
          on: Lesson.schoolID, .equal, School.id)
    .all()
if let row = rows.first {
    print(row.name) // String?
}
```

- `groupN {}`
  If it contains properties with the same name.

```swift
let rows = try await sql.selectWithColumns {
        Lesson.all
        group1 {
            School.id
            School.name
        }
    }
    ...
    .all()
if let row = rows.first {
    print(row.id) // LessonID
    print(row.group1.id) // SchoolID
}
```

- `#SQLColumnPropertyType(name:)`
  Build custom column expression

```swift
enum Alias {
    #SQLColumnPropertyType(name: "maxDate")
}

let row = try await sql.selectWithColumns {
    Alias.maxDate("max(\(Lesson.date))", as: Date?.self)
}
    .from(Lesson.self)
    .first()
if let row {
    print(row.maxDate) // Date?
}
```


## Eagerload

Eagerload children or slibling entities

```swift
@Schema
enum Student {
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
