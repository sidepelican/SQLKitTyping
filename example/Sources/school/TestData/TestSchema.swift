import Foundation
import SQLKitTyping

@Schema
enum Student: IDSchemaProtocol {
    static var tableName: String { "students" }
    typealias ID = GenericID<Self, UUID>

    let id: ID
    let name: String
    let age: Int?
}

@Schema
enum School: IDSchemaProtocol {
    static var tableName: String { "schools" }
    typealias ID = GenericID<Self, UUID>

    let id: ID
    let name: String

    @Children(for: \Lesson.schoolID)
    let lessons: Any
}

@Schema
enum SchoolStudentRelation: RelationSchemaProtocol {
    static var tableName: String { "schools_students" }

    let schoolID: School.ID
    let studentID: Student.ID

    static var relation: PivotJoinRelation<Self, School.ID, Student.ID> {
        .init(from: schoolID, to: studentID)
    }
}

@Schema
enum Lesson: IDSchemaProtocol {
    static var tableName: String { "lessons" }
    typealias ID = GenericID<Self, UUID>

    let id: ID
    let subject: String
    let schoolID: School.ID
    let date: Date?
    let createdAt: Date
}
