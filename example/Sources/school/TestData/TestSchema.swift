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

    struct __lessons<Child: Decodable>: ChildrenProperty, Decodable {
        var lessons: [Child]
    }
    static func lessons<Row: Decodable>() -> GenericReference<some TypedSQLColumn<Lesson, School.ID>, __lessons<Row>> {
        return .init(
            column: Lesson.schoolID,
            initProperty: __lessons.init
        )
    }
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
