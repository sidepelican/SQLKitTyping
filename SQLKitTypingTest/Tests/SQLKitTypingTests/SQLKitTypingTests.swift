import NIOCore
import NIOPosix
import SQLKit
import SQLKitTyping
import PostgresKit
import XCTest

final class SQLKitTypingTests: XCTestCase {
    static var eventLoopGroup: EventLoopGroup!
    static var sql: (any SQLDatabase)?
    var sql: any SQLDatabase { Self.sql! }

    class override func setUp() {
        super.setUp()

        eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)

        let conn = try! PostgresConnection.test(on: eventLoopGroup.next()).wait()
        let sql = conn.sql().print()
        Self.sql = sql

        try! resetTestDatabase(sql: sql)
    }

    class override func tearDown() {
        try! eventLoopGroup.syncShutdownGracefully()

        super.tearDown()
    }

    func testVersion() async throws {
        struct Row: Decodable {
            var version: String
        }
        let row = try await sql.raw("SELECT version();")
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
            .join(Lesson.tableName, on: School.id.withTable, .equal, Lesson.schoolID)
            .where(School.id.withTable, .equal, school1ID)
            .all(decoding: Row.self)

        XCTAssertEqual(rows.count, 3)
        XCTAssertEqual(Set(rows.map(\.subject)), ["foo", "bar", "baz"])
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
            .join(Lesson.tableName, on: School.id.withTable, .equal, Lesson.schoolID)
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
