import Foundation
import SQLKitTyping

struct StudentAll: Identifiable, Codable {
    @TypeOf(Student.id) var id
    @TypeOf(Student.name) var name
    @TypeOf(Student.age) var age

    init(id: ID,
         name: String,
         age: Int?) {
        self.id = id
        self.name = name
        self.age = age
    }
}

struct SchoolAll: Identifiable, Codable {
    @TypeOf(School.id) var id
    @TypeOf(School.name) var name

    init(id: ID,
         name: String) {
        self.id = id
        self.name = name
    }
}

struct LessonAll: Identifiable, Codable {
    @TypeOf(Lesson.id) var id
    @TypeOf(Lesson.subject) var subject
    @TypeOf(Lesson.schoolID) var schoolID

    init(id: ID,
         subject: String,
         schoolID: School.ID) {
        self.id = id
        self.subject = subject
        self.schoolID = schoolID
    }
}

