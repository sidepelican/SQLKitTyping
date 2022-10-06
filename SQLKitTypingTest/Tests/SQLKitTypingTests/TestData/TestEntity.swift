import Foundation
import SQLKitTyping

struct StudentAll: Identifiable, Codable {
    @Field(column: Student.id) var id
    @Field(column: Student.name) var name
    @Field(column: Student.age) var age

    init(id: ID,
         name: String,
         age: Int?) {
        self.id = id
        self.name = name
        self.age = age
    }
}

struct SchoolAll: Identifiable, Codable {
    @Field(column: School.id) var id
    @Field(column: School.name) var name

    init(id: ID,
         name: String) {
        self.id = id
        self.name = name
    }
}

struct LessonAll: Identifiable, Codable {
    @Field(column: Lesson.id) var id
    @Field(column: Lesson.subject) var subject
    @Field(column: Lesson.schoolID) var schoolID

    init(id: ID,
         subject: String,
         schoolID: School.ID) {
        self.id = id
        self.subject = subject
        self.schoolID = schoolID
    }
}

