import Foundation
import SQLKitTyping

@Schema
struct Student: IDSchemaProtocol, Codable, Sendable {
    static var tableName: String { "students" }
    typealias ID = GenericID<Self, UUID>

    var id: ID
    var name: String
    var age: Int?
}

@Schema
struct School: IDSchemaProtocol, Codable, Sendable {
    static var tableName: String { "schools" }
    typealias ID = GenericID<Self, UUID>

    var id: ID
    var name: String

    @Children(for: \Lesson.schoolID)
    var lessons: Any
}

@Schema
struct SchoolStudentRelation: RelationSchemaProtocol, Codable, Sendable {
    static var tableName: String { "schools_students" }

    var schoolID: School.ID
    var studentID: Student.ID

    static var relation: PivotJoinRelation<Self, School.ID, Student.ID> {
        .init(from: schoolID, to: studentID)
    }
}

@Schema
struct Lesson: IDSchemaProtocol, Codable, Sendable {
    static var tableName: String { "lessons" }
    typealias ID = GenericID<Self, UUID>

    var id: ID
    var subject: String
    var schoolID: School.ID
    var date: Date?
    var createdAt: Date
}
