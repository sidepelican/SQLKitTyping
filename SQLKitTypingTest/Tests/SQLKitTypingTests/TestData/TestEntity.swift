import Foundation
import SQLKitTyping

struct StudentAll: IDModel, Encodable {
    typealias Schema = Student

    @Field(column: \.id) var id
    @Field(column: \.name) var name
    @Field(column: \.age) var age

    init(id: ID,
         name: String,
         age: Int?) {
        self.id = id
        self.name = name
        self.age = age
    }
}

struct SchoolAll: IDModel, Encodable {
    typealias Schema = School

    @Field(column: \.id) var id
    @Field(column: \.name) var name

    init(id: ID,
         name: String) {
        self.id = id
        self.name = name
    }
}

struct LessonAll: IDModel, Encodable {
    typealias Schema = Lesson

    @Field(column: \.id) var id
    @Field(column: \.subject) var subject
    @Field(column: \.schoolID) var schoolID

    init(id: ID,
         subject: String,
         schoolID: School.ID) {
        self.id = id
        self.subject = subject
        self.schoolID = schoolID
    }
}

