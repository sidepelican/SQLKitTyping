import Foundation
import SQLKit

extension SQLDatabase {
    public func insert<Schema: SchemaProtocol>(into schema: Schema) -> SQLInsertBuilder {
        return self.insert(into: SQLIdentifier(schema.tableName))
    }

    public func delete<Schema: SchemaProtocol>(from schema: Schema) -> SQLDeleteBuilder {
        return self.delete(from: SQLIdentifier(schema.tableName))
    }
}

extension SQLSelectBuilder {
    @discardableResult
    public func from<Schema: SchemaProtocol>(_ schema: Schema) -> Self {
        return self.from(SQLIdentifier(Schema.tableName))
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
    public func update<Schema: SchemaProtocol>(_ schema: Schema) -> SQLUpdateBuilder {
        return self.update(SQLIdentifier(Schema.tableName))
    }
}

extension SchemaProtocol {
    public var all: SQLColumn {
        SQLColumn(SQLLiteral.all)
    }

    public var allWithTable: SQLColumn {
        SQLColumn(SQLLiteral.all, table: SQLIdentifier(Self.tableName))
    }
}
