@preconcurrency import Foundation
import SQLKitTyping

struct Student: IDSchemaProtocol {
    static var tableName: String { "students" }
    typealias ID = GenericID<Self, UUID>

    let id = Column<ID>("id")
    let name = Column<String>("name")
    let age = Column<Int?>("age")
}

struct School: IDSchemaProtocol {
    static var tableName: String { "schools" }
    typealias ID = GenericID<Self, UUID>

    let id = Column<ID>("id")
    let name = Column<String>("name")
}

struct SchoolStudentRelation: RelationSchemaProtocol {
    static var tableName: String { "schools_students" }

    let schoolID = Column<School.ID>("schoolID")
    let studentID = Column<Student.ID>("studentID")

    var relation: PivotJoinRelation<Self, School.ID, Student.ID> {
        .init(self, from: \.schoolID, to: \.studentID)
    }
}

struct Lesson: IDSchemaProtocol {
    static var tableName: String { "lessons" }
    typealias ID = GenericID<Self, UUID>

    let id = Column<ID>("id")
    let subject = Column<String>("subject")
    let schoolID = Column<School.ID>("schoolID")
}
