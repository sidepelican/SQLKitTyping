import SQLKit

struct Foo {}
extension Foo {

    #SQLColumnPropertyType(name: "email")

    func playground(db: any SQLDatabase) async throws {
        //    print(Email.self)

        let row = try await db.selectWithColumns {
            UserTable.all
            email(SQLLiteral.string("foo@example.com"), as: String.self)
            group1 {
                UserTable.familyName(SQLLiteral.string("aaa")).nullable
                UserTable.familyNameKana.nullable
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

        print(row.email)
        print(row.values.0.familyName)
//        print(row.group1.familyNameKana ?? "null")
        //    print(row.email)
    }

    enum CodingKeys: CodingKey {
        init?(stringValue: String) {
            guard stringValue == "" else {
                return nil
            }
            self = .aa
        }
        case aa
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
