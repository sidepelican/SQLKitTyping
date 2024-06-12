import SQLKit

struct Foo {}
extension Foo {

    #SQLColumnPropertyType(name: "Email", type: String.self)
    
    func playground(db: any SQLDatabase) async throws {
        //    print(Email.self)

        let row = try await db.selectWithColumns {
            UserTable.all
            Email(SQLLiteral.string("foo@example.com"))
            group1 {
                UserTable.familyName
                UserTable.familyNameKana
            }
        }
            .from(UserTable.self)
            .join("emails", on: UserTable.id.withTable, .equal, SQLColumn("userID", table: "emails"))
            .where(UserTable.id, .equal, 123)
            .first()!
        //    UserTable.fami
        let row2 = try await db.insert(into: UserTable.self)
            .returning(UserTable.tel)
            .first()?.tel

        print(row.Email)
        print(row.values.0.familyName)
        print(row.group1.familyNameKana ?? "null")
        //    print(row.email)
    }
}


@Schema
package struct UserTable: SchemaProtocol {
    package static var tableName: String { "users" }

    package var id: Int
    package var familyName: String
    package var givenName: String
    package var familyNameKana: String?
    package var givenNameKana: String?
    package var tel: String
}
