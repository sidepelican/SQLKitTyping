# SQLKitTyping

Add slightly type safe interface for SQLKit.

# Install

```swift
.package(url: "https://github.com/sidepelican/SQLKitTyping.git", from: "..."),
```

# Usage

Define a table entity type and add the `@Schema` macro.
(Ensure to also include the `tableName` property. The `@Schema` macro adds the `SchemaProtocol` which requires `tableName`.)

```swift
@Schema
struct School: Sendable {
    static var tableName: String { "schools" }

    var id: SchoolID
    var name: String
}
```

The `@Schema` macro provides static properties for column expressions, including their types.

```swift
School.id // some TypedSQLColumn<School, SchoolID>
School.name // some TypedSQLColumn<School, String>
```

Query with type safe columns.

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

## Query Individual Columns

`sql.selectWithColumns` can query individual columns and return results in rows with the specified column properties.

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

Combine with other tables.

```swift
@Schema
struct Lesson: Sendable {
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

### Additional Utilities

- `.nullable`
   Use when a JOIN operation makes the column type nullable.

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
  Use if there are properties with the same name.

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
  Build custom column expressions.

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

`#hasMany` and `#hasOne` provides methods to eagerload child or slibling entities

```swift
@Schema
struct School: Sendable {
    static var tableName: String { "schools" }

    var id: SchoolID
    var name: String

    #hasMany(propertyName: "lessons", mappedBy: \Lesson.schoolID)
}

@Schema
struct Lesson: Sendable {
    static var tableName: String { "lessons" }

    var id: LessonID
    var subject: String
    var schoolID: SchoolID
    var date: Date?
}

let rows = try await sql.selectWithColumn(School.all)
    .from(School.self)
    .all()
    .eagerLoadMany(sql: sql, for: \.id, using: School.lessons.self)

if let row = rows.first, if let lesson = rows.lessons.first {
    print(lesson.date) // Date?
}
```
