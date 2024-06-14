import SQLKit
import SQLKitTyping
import SQLiteKit
import XCTest

final class SchoolTests: XCTestCase {
    static var sql: Task<any SQLDatabase, any Error>?
    var sql: any SQLDatabase { 
        get async throws { try await Self.sql!.value }
    }

    class override func setUp() {
        super.setUp()

        let source = SQLiteConnectionSource(
            configuration: .init(storage: .memory)
        )
        let logger = Logger(label: "school")

        Self.sql = Task {
            let conn = try await source.makeConnection(logger: logger, on: MultiThreadedEventLoopGroup.singleton.next()).get()
            let sql = conn.sql(queryLogLevel: .info)
            try resetTestDatabase(sql: sql)
            return sql
        }
    }

    func testVersion() async throws {
        struct Row: Decodable {
            var version: String
        }
        let row = try await sql.raw("SELECT sqlite_version() as version")
            .first(decoding: Row.self)

        print(try XCTUnwrap(row).version)
    }

    func testTypedColumn() async throws {
        var rows = try await sql.select()
            .column(Student.all)
            .from(Student.self)
            .where(Student.age, .greaterThanOrEqual , 42)
            .all(decoding: StudentAll.self)

        XCTAssertEqual(rows.count, 1)

        rows = try await sql.select()
            .column(Student.all)
            .from(Student.self)
            .where(Student.age, .is, SQLLiteral.null)
            .all(decoding: StudentAll.self)

        XCTAssertEqual(rows.count, 2)
    }

    func testColumnWithTable() async throws {
        struct Row: Decodable {
            var subject: String
        }

        let rows = try await sql.select()
            .column(Lesson.subject)
            .from(School.self)
            .join(Lesson.self, on: School.id, .equal, Lesson.schoolID)
            .where(School.id.withTable, .equal, school1ID)
            .all(decoding: Row.self)

        XCTAssertEqual(rows.count, 3)
        XCTAssertEqual(Set(rows.map(\.subject)), ["foo", "bar", "baz"])
    }

    func testUpdateColumn() async throws {
        try await sql.update(Student.self)
            .set(Student.age, to: 21)
            .where(Student.id, .equal, student4ID)
            .run()
    }

    func testJoinedColumn() async throws {
        struct Row: Decodable, Identifiable {
            @TypeOf(Lesson.id) var id
            @TypeOf(Lesson.subject) var subject
            @TypeOf(School.name) var schoolName
        }

        let rows = try await sql.select()
            .column(Lesson.all)
            .column(School.name, as: "schoolName")
            .from(School.self)
            .join(Lesson.self, on: School.id, .equal, Lesson.schoolID)
            .all(decoding: Row.self)

        XCTAssertEqual(rows.count, 9)
        XCTAssertEqual(Set(rows.map(\.schoolName)), ["shibuya", "shinjyuku", "ikebukuro"])
    }

    func testParentEagerLoad() async throws {
        struct SchoolWithLessons: Decodable, Identifiable {
            @TypeOf(School.id) var id
            @TypeOf(School.name) var name
            var lessons: [LessonAll] = []

            enum CodingKeys: String, CodingKey {
                case id
                case name
            }
        }

        var row = try await sql.select()
            .column(School.all)
            .from(School.self)
            .where(School.id, .equal, school1ID)
            .first(decoding: SchoolWithLessons.self)
        try await sql.eagerLoadAllColumns(into: &row, keyPath: \.lessons, column: Lesson.schoolID)
        XCTAssertEqual(row?.lessons.count, 3)

        var rows = try await sql.select()
            .column(School.all)
            .from(School.self)
            .all(decoding: SchoolWithLessons.self)
        try await sql.eagerLoadAllColumns(into: &rows, keyPath: \.lessons, column: Lesson.schoolID)
        XCTAssertEqual(rows.map(\.lessons.count), [3, 3, 3])
    }

    func testPivotEagerLoad() async throws {
        struct SchoolWithStudents: Decodable, Identifiable {
            @TypeOf(School.id) var id
            @TypeOf(School.name) var name
            var students: [StudentAll] = []

            enum CodingKeys: String, CodingKey {
                case id
                case name
            }
        }

        var row = try await sql.select()
            .column(School.all)
            .from(School.self)
            .where(School.id, .equal, school1ID)
            .first(decoding: SchoolWithStudents.self)
        try await sql.eagerLoadAllColumns(into: &row, keyPath: \.students,
                                          targetTable: Student.self,
                                          relationTable: SchoolStudentRelation.self)
        XCTAssertEqual(row?.students.count, 4)

        var rows = try await sql.select()
            .column(School.all)
            .from(School.self)
            .all(decoding: SchoolWithStudents.self)
        try await sql.eagerLoadAllColumns(into: &rows, keyPath: \.students,
                                          targetTable: Student.self,
                                          relationTable: SchoolStudentRelation.self)
        XCTAssertEqual(Set(rows.map(\.students.count)), [4, 3, 0])
    }
}
