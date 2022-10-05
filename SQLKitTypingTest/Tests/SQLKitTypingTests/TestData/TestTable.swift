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

func resetTestDatabase(sql: any SQLDatabase) throws {
    let student = Student()
    let school = School()
    let schoolStudent = SchoolStudentRelation()
    let lesson = Lesson()
    try sql.drop(table: lesson).ifExists().run().wait()
    try sql.drop(table: schoolStudent).ifExists().run().wait()
    try sql.drop(table: school).ifExists().run().wait()
    try sql.drop(table: student).ifExists().run().wait()

    try sql.create(table: student)
        .column(student.id, type: SQLDataType.uuid, SQLColumnConstraintAlgorithm.primaryKey(autoIncrement: false))
        .column(student.name, type: SQLDataType.text, SQLColumnConstraintAlgorithm.notNull)
        .column(student.age, type: SQLDataType.int)
        .run().wait()

    try sql.create(table: school)
        .column(school.id, type: SQLDataType.uuid, SQLColumnConstraintAlgorithm.primaryKey(autoIncrement: false))
        .column(school.name, type: SQLDataType.text, SQLColumnConstraintAlgorithm.notNull)
        .run().wait()

    try sql.create(table: schoolStudent)
        .column(schoolStudent.schoolID, type: SQLDataType.uuid, SQLColumnConstraintAlgorithm.references(school, school.id))
        .column(schoolStudent.studentID, type: SQLDataType.uuid, SQLColumnConstraintAlgorithm.references(student, student.id))
        .primaryKey([schoolStudent.schoolID, schoolStudent.studentID])
        .run().wait()

    try sql.create(table: lesson)
        .column(lesson.id, type: SQLDataType.uuid, SQLColumnConstraintAlgorithm.primaryKey(autoIncrement: false))
        .column(lesson.subject, type: SQLDataType.text, SQLColumnConstraintAlgorithm.notNull)
        .column(lesson.schoolID, type: SQLDataType.uuid, SQLColumnConstraintAlgorithm.references(school, school.id))
        .run().wait()

    try sql.insert(into: student)
        .models([
            StudentAll(id: student1ID, name: "ichiro", age: 42),
            StudentAll(id: student2ID, name: "jiro", age: nil),
            StudentAll(id: student3ID, name: "saburo", age: nil),
            StudentAll(id: student4ID, name: "shiro", age: 20),
            StudentAll(id: student5ID, name: "goro", age: 16),
        ])
        .run().wait()

    try sql.insert(into: school)
        .models([
            SchoolAll(id: school1ID, name: "shibuya"),
            SchoolAll(id: school2ID, name: "ikebukuro"),
            SchoolAll(id: school3ID, name: "shinjyuku"),
        ])
        .run().wait()

    try sql.insert(into: schoolStudent)
        .columns(schoolStudent.schoolID, schoolStudent.studentID)
        .values(school1ID, student1ID)
        .values(school1ID, student2ID)
        .values(school1ID, student3ID)
        .values(school1ID, student4ID)
        .values(school2ID, student1ID)
        .values(school2ID, student2ID)
        .values(school2ID, student3ID)
        .run().wait()

    try sql.insert(into: lesson)
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
        .run().wait()
}

extension SQLDataType {
    static var uuid: SQLExpression {
        SQLRaw("UUID")
    }
}
