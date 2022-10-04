import Foundation
import SQLKit

extension SQLDatabase {
    func insert<Schema: SchemaProtocol>(into schema: Schema) -> SQLInsertBuilder {
        return self.insert(into: SQLIdentifier(schema.tableName))
    }

    func delete<Schema: SchemaProtocol>(from schema: Schema) -> SQLDeleteBuilder {
        return self.delete(from: SQLIdentifier(schema.tableName))
    }
}

extension SQLSelectBuilder {
    @discardableResult
    func from<Schema: SchemaProtocol>(_ schema: Schema) -> Self {
        return self.from(SQLIdentifier(Schema.tableName))
    }
}

extension SQLPredicateBuilder {
    @discardableResult
    func `where`<S, E>(_ lhs: TypedSQLColumn<S, E>, _ op: SQLBinaryOperator, _ rhs: E) -> Self
        where E: Encodable
    {
        return self.where(lhs, op, SQLBind(rhs))
    }

    @discardableResult
    func `where`<S, E>(_ lhs: TypedSQLColumn<S, E>, _ op: SQLBinaryOperator, _ rhs: [E]) -> Self
        where E: Encodable
    {
        return self.where(lhs, op, SQLBind.group(rhs))
    }
}

extension SQLDatabase {
    func update<Schema: SchemaProtocol>(_ schema: Schema) -> SQLUpdateBuilder {
        return self.update(SQLIdentifier(Schema.tableName))
    }
}

extension SchemaProtocol {
    var all: SQLColumn {
        SQLColumn(SQLLiteral.all)
    }

    var allWithTable: SQLColumn {
        SQLColumn(SQLLiteral.all, table: SQLIdentifier(Self.tableName))
    }
}
