import Foundation
import SQLKitTyping

typealias StudentID = GenericID<Student, UUID>

@Schema
struct Student: IDSchemaProtocol, Codable, Sendable {
    static var tableName: String { "students" }

    var id: StudentID
    var name: String
    var age: Int?
}

typealias SchoolID = GenericID<School, UUID>

@Schema
struct School: IDSchemaProtocol, Codable, Sendable {
    static var tableName: String { "schools" }

    var id: SchoolID
    var name: String

    #hasMany(name: "lessons", mappedBy: \Lesson.schoolID)
}

@Schema
struct SchoolStudentRelation: RelationSchemaProtocol, Codable, Sendable {
    static var tableName: String { "schools_students" }

    var schoolID: SchoolID
    var studentID: StudentID

    static var relation: PivotJoinRelation<Self, School.ID, Student.ID> {
        .init(from: schoolID, to: studentID)
    }
}

typealias LessonID = GenericID<Lesson, UUID>

@Schema
struct Lesson: IDSchemaProtocol, Codable, Sendable {
    static var tableName: String { "lessons" }

    var id: LessonID
    var subject: String
    var schoolID: SchoolID
    var date: Date?
    var createdAt: Date
}
