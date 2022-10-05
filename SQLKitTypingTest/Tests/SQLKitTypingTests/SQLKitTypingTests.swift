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
        let student = Student()

        var rows = try await sql.select()
            .column(student.all)
            .from(student)
            .where(student.age, .greaterThanOrEqual , 42)
            .all(decoding: StudentAll.self)

        XCTAssertEqual(rows.count, 1)

        rows = try await sql.select()
            .column(student.all)
            .from(student)
            .where(student.age, .is, SQLLiteral.null)
            .all(decoding: StudentAll.self)

        XCTAssertEqual(rows.count, 2)
    }

    func testColumnWithTable() async throws {
        let school = School()
        let lesson = Lesson()

        struct Row: Decodable {
            var subject: String
        }

        let rows = try await sql.select()
            .column(lesson.subject)
            .from(school)
            .join(lesson, on: school.id.withTable, .equal, lesson.schoolID)
            .where(school.id.withTable, .equal, school1ID)
            .all(decoding: Row.self)

        XCTAssertEqual(rows.count, 3)
        XCTAssertEqual(Set(rows.map(\.subject)), ["foo", "bar", "baz"])
    }

    func testJoinedColumn() async throws {
        struct Row: IDModel {
            typealias Schema = Lesson
            @Field(column: \.id) var id
            @Field(column: \.subject) var subject
            @ModelField(column: \School.name) var schoolName
        }

        let school = School()
        let lesson = Lesson()

        let rows = try await sql.select()
            .column(lesson.all)
            .column(school.name, as: "schoolName")
            .from(school)
            .join(lesson, on: school.id.withTable, .equal, lesson.schoolID)
            .all(decoding: Row.self)

        XCTAssertEqual(rows.count, 9)
        XCTAssertEqual(Set(rows.map(\.schoolName)), ["shibuya", "shinjyuku", "ikebukuro"])
    }

    func testParentEagerLoad() async throws {
        struct SchoolWithLessons: IDModel {
            typealias Schema = School

            @Field(column: \.id) var id
            @Field(column: \.name) var name
            var lessons: [LessonAll] = []

            enum CodingKeys: String, CodingKey {
                case id
                case name
            }
        }

        let school = School()

        var row = try await sql.select()
            .column(school.all)
            .from(school)
            .where(school.id, .equal, school1ID)
            .first(decoding: SchoolWithLessons.self)
        try await sql.eagerLoadAllColumns(into: &row, keyPath: \.lessons, column: Lesson().schoolID)
        XCTAssertEqual(row?.lessons.count, 3)

        var rows = try await sql.select()
            .column(school.all)
            .from(school)
            .all(decoding: SchoolWithLessons.self)
        try await sql.eagerLoadAllColumns(into: &rows, keyPath: \.lessons, column: Lesson().schoolID)
        XCTAssertEqual(rows.map(\.lessons.count), [3, 3, 3])
    }

    func testPivotEagerLoad() async throws {
        struct SchoolWithStudents: IDModel {
            typealias Schema = School

            @Field(column: \.id) var id
            @Field(column: \.name) var name
            var students: [StudentAll] = []

            enum CodingKeys: String, CodingKey {
                case id
                case name
            }
        }

        let school = School()

        var row = try await sql.select()
            .column(school.all)
            .from(school)
            .where(school.id, .equal, school1ID)
            .first(decoding: SchoolWithStudents.self)
        try await sql.eagerLoadAllColumns(into: &row, keyPath: \.students,
                                          targetTable: Student(),
                                          relationTable: SchoolStudentRelation())
        XCTAssertEqual(row?.students.count, 4)

        var rows = try await sql.select()
            .column(school.all)
            .from(school)
            .all(decoding: SchoolWithStudents.self)
        try await sql.eagerLoadAllColumns(into: &rows, keyPath: \.students,
                                          targetTable: Student(),
                                          relationTable: SchoolStudentRelation())
        XCTAssertEqual(Set(rows.map(\.students.count)), [4, 3, 0])
    }
}
