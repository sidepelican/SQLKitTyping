import Foundation
import SQLKit
import SQLKitTyping

let student1ID = Student.ID(.init())
let student2ID = Student.ID(.init())
let student3ID = Student.ID(.init())
let student4ID = Student.ID(.init())
let student5ID = Student.ID(.init())
let school1ID = School.ID(.init())
let school2ID = School.ID(.init())
let school3ID = School.ID(.init())

func resetTestDatabase(sql: any SQLDatabase) async throws {
    sql.logger.info("------- Setup testing database -------")
    defer {
        sql.logger.info("------- Setup testing database end -------")
    }

    try await sql.drop(table: Lesson.self).ifExists().run()
    try await sql.drop(table: SchoolStudentRelation.self).ifExists().run()
    try await sql.drop(table: School.self).ifExists().run()
    try await sql.drop(table: Student.self).ifExists().run()

    try await sql.create(table: Student.self)
        .column(Student.id, type: SQLDataType.uuid, SQLColumnConstraintAlgorithm.primaryKey(autoIncrement: false))
        .column(Student.name, type: SQLDataType.text, SQLColumnConstraintAlgorithm.notNull)
        .column(Student.age, type: SQLDataType.int)
        .run()

    try await sql.create(table: School.self)
        .column(School.id, type: SQLDataType.uuid, SQLColumnConstraintAlgorithm.primaryKey(autoIncrement: false))
        .column(School.name, type: SQLDataType.text, SQLColumnConstraintAlgorithm.notNull)
        .run()

    try await sql.create(table: SchoolStudentRelation.self)
        .column(SchoolStudentRelation.schoolID, type: SQLDataType.uuid, SQLColumnConstraintAlgorithm.references(School.tableName, School.id.name))
        .column(SchoolStudentRelation.studentID, type: SQLDataType.uuid, SQLColumnConstraintAlgorithm.references(Student.tableName, Student.id.name))
        .primaryKey([SchoolStudentRelation.schoolID, SchoolStudentRelation.studentID])
        .run()

    try await sql.create(table: Lesson.self)
        .column(Lesson.id, type: SQLDataType.uuid, SQLColumnConstraintAlgorithm.primaryKey(autoIncrement: false))
        .column(Lesson.subject, type: SQLDataType.text, SQLColumnConstraintAlgorithm.notNull)
        .column(Lesson.schoolID, type: SQLDataType.uuid, SQLColumnConstraintAlgorithm.references(School.tableName, School.id.name))
        .column(Lesson.date, type: SQLDataType.timestamp)
        .column(Lesson.createdAt, type: SQLDataType.timestamp, SQLColumnConstraintAlgorithm.notNull, SQLColumnConstraintAlgorithm.default(SQLCurrentTimestamp()))
        .run()

    try await sql.insert(into: Student.self)
        .models([
            Student(id: student1ID, name: "ichiro", age: 42),
            Student(id: student2ID, name: "jiro", age: nil),
            Student(id: student3ID, name: "saburo", age: nil),
            Student(id: student4ID, name: "shiro", age: 20),
            Student(id: student5ID, name: "goro", age: 16),
        ], nilEncodingStrategy: .asNil)
        .run()

    try await sql.insert(into: School.self)
        .models([
            School(id: school1ID, name: "ikebukuro"),
            School(id: school2ID, name: "shibuya"),
            School(id: school3ID, name: "shinjyuku"),
        ], nilEncodingStrategy: .asNil)
        .run()

    try await sql.insert(into: SchoolStudentRelation.self)
        .columnsAndValues(
            columns: SchoolStudentRelation.schoolID, SchoolStudentRelation.studentID,
            values: [
                (school1ID, student1ID),
                (school1ID, student2ID),
                (school1ID, student3ID),
                (school1ID, student4ID),
                (school2ID, student1ID),
                (school2ID, student2ID),
                (school2ID, student3ID),
            ]
        )
        .run()

    try await sql.insert(into: Lesson.self)
        .columnsAndValues(
            columns: Lesson.id, Lesson.subject, Lesson.schoolID, Lesson.date,
            values: [
                (.init(.init()), "foo1", school1ID, .now),
                (.init(.init()), "bar1", school1ID, .now),
                (.init(.init()), "baz1", school1ID, .now),
                (.init(.init()), "foo2", school2ID, .now),
                (.init(.init()), "bar2", school2ID, .now),
                (.init(.init()), "baz2", school2ID, nil),
                (.init(.init()), "foo3", school3ID, nil),
                (.init(.init()), "bar3", school3ID, nil),
                (.init(.init()), "baz3", school3ID, nil),
            ]
        )
        .run()
}

extension SQLDataType {
    static var uuid: any SQLExpression {
        SQLRaw("UUID")
    }
}
