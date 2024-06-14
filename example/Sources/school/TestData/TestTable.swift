import Foundation
import SQLKit

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
        .run()

    try await sql.insert(into: Student.self)
        .models([
            StudentAll(id: student1ID, name: "ichiro", age: 42),
            StudentAll(id: student2ID, name: "jiro", age: nil),
            StudentAll(id: student3ID, name: "saburo", age: nil),
            StudentAll(id: student4ID, name: "shiro", age: 20),
            StudentAll(id: student5ID, name: "goro", age: 16),
        ])
        .run()

    try await sql.insert(into: School.self)
        .models([
            SchoolAll(id: school1ID, name: "shibuya"),
            SchoolAll(id: school2ID, name: "ikebukuro"),
            SchoolAll(id: school3ID, name: "shinjyuku"),
        ])
        .run()

    try await sql.insert(into: SchoolStudentRelation.self)
        .columns(SchoolStudentRelation.schoolID, SchoolStudentRelation.studentID)
        .values(school1ID, student1ID)
        .values(school1ID, student2ID)
        .values(school1ID, student3ID)
        .values(school1ID, student4ID)
        .values(school2ID, student1ID)
        .values(school2ID, student2ID)
        .values(school2ID, student3ID)
        .run()

    try await sql.insert(into: Lesson.self)
        .models([
            LessonAll(id: .init(.init()), subject: "foo", schoolID: school1ID),
            LessonAll(id: .init(.init()), subject: "bar", schoolID: school1ID),
            LessonAll(id: .init(.init()), subject: "baz", schoolID: school1ID),
            LessonAll(id: .init(.init()), subject: "foo", schoolID: school2ID),
            LessonAll(id: .init(.init()), subject: "bar", schoolID: school2ID),
            LessonAll(id: .init(.init()), subject: "baz", schoolID: school2ID),
            LessonAll(id: .init(.init()), subject: "foo", schoolID: school3ID),
            LessonAll(id: .init(.init()), subject: "bar", schoolID: school3ID),
            LessonAll(id: .init(.init()), subject: "baz", schoolID: school3ID),
        ])
        .run()
}

extension SQLDataType {
    static var uuid: any SQLExpression {
        SQLRaw("UUID")
    }
}
