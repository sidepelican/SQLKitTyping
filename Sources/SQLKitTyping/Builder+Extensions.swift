import Foundation
import SQLKit

extension SQLDatabase {
    public func create<Schema: SchemaProtocol>(table schema: Schema.Type) -> SQLCreateTableBuilder {
        return self.create(table: SQLIdentifier(schema.tableName))
    }

    public func insert<Schema: SchemaProtocol>(into schema: Schema.Type) -> SQLInsertBuilder {
        return self.insert(into: SQLIdentifier(schema.tableName))
    }

    public func delete<Schema: SchemaProtocol>(from schema: Schema.Type) -> SQLDeleteBuilder {
        return self.delete(from: SQLIdentifier(schema.tableName))
    }

    public func drop<Schema: SchemaProtocol>(table schema: Schema.Type) -> SQLDropTableBuilder {
        return self.drop(table: SQLIdentifier(schema.tableName))
    }
}

extension SQLSelectBuilder {
    @discardableResult
    public func from<Schema: SchemaProtocol>(_ schema: Schema.Type) -> Self {
        return self.from(SQLIdentifier(schema.tableName))
    }
}

extension SQLPredicateBuilder {
    @discardableResult
    public func `where`<S, E>(_ lhs: TypedSQLColumn<S, E>, _ op: SQLBinaryOperator, _ rhs: E) -> Self
        where E: Encodable
    {
        return self.where(lhs, op, SQLBind(rhs))
    }

    @discardableResult
    public func `where`<S, E>(_ lhs: TypedSQLColumn<S, E>, _ op: SQLBinaryOperator, _ rhs: [E]) -> Self
        where E: Encodable
    {
        return self.where(lhs, op, SQLBind.group(rhs))
    }
}

extension SQLDatabase {
    public func update<Schema: SchemaProtocol>(_ schema: Schema.Type) -> SQLUpdateBuilder {
        return self.update(SQLIdentifier(schema.tableName))
    }
}

extension SchemaProtocol {
    public static var all: SQLColumn {
        SQLColumn(SQLLiteral.all)
    }

    public static var allWithTable: SQLColumn {
        SQLColumn(SQLLiteral.all, table: SQLIdentifier(Self.tableName))
    }
}
