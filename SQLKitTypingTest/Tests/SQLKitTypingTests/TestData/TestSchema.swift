@preconcurrency import Foundation
import SQLKitTyping

enum Student: IDSchemaProtocol {
    static var tableName: String { "students" }
    typealias ID = GenericID<Self, UUID>

    static let id = Column<ID>("id")
    static let name = Column<String>("name")
    static let age = Column<Int?>("age")
}

enum School: IDSchemaProtocol {
    static var tableName: String { "schools" }
    typealias ID = GenericID<Self, UUID>

    static let id = Column<ID>("id")
    static let name = Column<String>("name")
}

enum SchoolStudentRelation: RelationSchemaProtocol {
    static var tableName: String { "schools_students" }

    static let schoolID = Column<School.ID>("schoolID")
    static let studentID = Column<Student.ID>("studentID")

    static var relation: PivotJoinRelation<Self, School.ID, Student.ID> {
        .init(from: schoolID, to: studentID)
    }
}

enum Lesson: IDSchemaProtocol {
    static var tableName: String { "lessons" }
    typealias ID = GenericID<Self, UUID>

    static let id = Column<ID>("id")
    static let subject = Column<String>("subject")
    static let schoolID = Column<School.ID>("schoolID")
}
