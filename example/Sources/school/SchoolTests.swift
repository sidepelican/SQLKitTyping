import SQLKit
import SQLKitTyping
import SQLiteKit
import XCTest

final class SchoolTests: XCTestCase {
    static nonisolated(unsafe) var sql: Task<(any SQLDatabase, SQLiteConnection), any Error>?
    var sql: any SQLDatabase {
        get async throws { try await Self.sql!.value.0 }
    }

    class override func setUp() {
        super.setUp()

        let source = SQLiteConnectionSource(
            configuration: .init(storage: .memory)
        )
        let logger = Logger(label: "school")

        Self.sql = Task {
            let conn = try await source.makeConnection(logger: logger, on: MultiThreadedEventLoopGroup.singleton.next()).get()
            do {
                let sql = conn.sql(queryLogLevel: .info)
                try await resetTestDatabase(sql: sql)
                return (sql, conn)
            } catch {
                print(String(reflecting: error))
                try! await conn.close()
                throw error
            }
        }
    }

    class override func tearDown() {
        Task {
            try await Self.sql?.value.1.close()
            Self.sql = nil
        }
        super.tearDown()
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
        var rows = try await sql.selectWithColumn(Student.all)
            .from(Student.self)
            .where(Student.age, .greaterThanOrEqual , 42)
            .all()

        XCTAssertEqual(rows.count, 1)

        rows = try await sql.select()
            .column(Student.all)
            .from(Student.self)
            .where(Student.age, .is, SQLLiteral.null)
            .all(decoding: StudentTypes.All.self)

        XCTAssertEqual(rows.count, 2)
    }

    func testColumnWithTable() async throws {
        let rows = try await sql.selectWithColumn(Lesson.subject)
            .from(School.self)
            .join(Lesson.self, on: School.id, .equal, Lesson.schoolID)
            .where(School.id.withTable, .equal, school1ID)
            .all()

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
        let rows = try await sql.selectWithColumns {
            Lesson.all
            School.name
        }
            .from(School.self)
            .join(Lesson.self, on: School.id, .equal, Lesson.schoolID)
            .all()

        XCTAssertEqual(rows.count, 9)
        XCTAssertEqual(Set(rows.map(\.name)), ["shibuya", "shinjyuku", "ikebukuro"])
    }

    func testParentEagerLoad() async throws {
        struct SchoolWithLessons: Decodable, Identifiable {
            @TypeOf(School.id) var id
            @TypeOf(School.name) var name
            var lessons: [LessonTypes.All] = []

            enum CodingKeys: String, CodingKey {
                case id
                case name
            }
        }

        let row = try await sql.selectWithColumn(School.all)
            .from(School.self)
            .where(School.id, .equal, school1ID)
            .first()
            .eagerLoad(sql: sql, for: \.id, School.lessons) {
                Lesson.all
            }
        XCTAssertEqual(row?.lessons.count, 3)
        XCTAssertEqual(row?.lessons.map { $0.subject }.sorted(), ["bar1", "baz1", "foo1"])

        let rows = try await sql.selectWithColumn(School.all)
            .from(School.self)
            .orderBy(School.name)
            .all()
            .eagerLoad(sql: sql, for: \.id, School.lessons) {
                Lesson.all
            }
        XCTAssertEqual(rows.map(\.lessons.count), [3, 3, 3])
        if rows.count == 3 {
            XCTAssertEqual(rows[0].name, "ikebukuro")
            XCTAssertEqual(rows[0].lessons.map { $0.subject }.sorted(), ["bar1", "baz1", "foo1"])
            XCTAssertEqual(rows[1].name, "shibuya")
            XCTAssertEqual(rows[1].lessons.map { $0.subject }.sorted(), ["bar2", "baz2", "foo2"])
            XCTAssertEqual(rows[2].name, "shinjyuku")
            XCTAssertEqual(rows[2].lessons.map { $0.subject }.sorted(), ["bar3", "baz3", "foo3"])
        }
    }

    func testPivotEagerLoad() async throws {
        struct SchoolWithStudents: Decodable, Identifiable {
            @TypeOf(School.id) var id
            @TypeOf(School.name) var name
            var students: [StudentTypes.All] = []

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
