import SQLKit

extension SQLDatabase {
    @inlinable
    public func eagerLoadAllColumns<
        Row: IDModel,
        RelationSchema: SchemaProtocol,
        TargetSchema: IDSchemaProtocol,
        FromID: IDType,
        ToID: IDType,
        Decoding: Decodable
    >(
        into row: inout Row?,
        keyPath: WritableKeyPath<Row, [Decoding]>,
        targetTable: TargetSchema,
        relation: PivotJoinRelation<RelationSchema, FromID, ToID>
    ) async throws
    where Row.Schema.ID == FromID, TargetSchema.ID == ToID
    {
        try await select()
            .column(targetTable.all)
            .from(targetTable)
            .eagerLoad(into: &row, keyPath: keyPath, toIDColumn: targetTable.id, relation: relation)
    }

    @inlinable
    public func eagerLoadAllColumns<
        Row: IDModel,
        RelationSchema: RelationSchemaProtocol,
        TargetSchema: IDSchemaProtocol,
        Decoding: Decodable
    >(
        into row: inout Row?,
        keyPath: WritableKeyPath<Row, [Decoding]>,
        targetTable: TargetSchema,
        relationTable: RelationSchema
    ) async throws
    where Row.Schema.ID == RelationSchema.ID1, TargetSchema.ID == RelationSchema.ID2
    {
        try await eagerLoadAllColumns(into: &row, keyPath: keyPath, targetTable: targetTable, relation: relationTable.relation)
    }

    @inlinable
    public func eagerLoadAllColumns<
        Row: IDModel,
        RelationSchema: RelationSchemaProtocol,
        TargetSchema: IDSchemaProtocol,
        Decoding: Decodable
    >(
        into row: inout Row?,
        keyPath: WritableKeyPath<Row, [Decoding]>,
        targetTable: TargetSchema,
        relationTable: RelationSchema
    ) async throws
    where Row.Schema.ID == RelationSchema.ID2, TargetSchema.ID == RelationSchema.ID1
    {
        try await eagerLoadAllColumns(into: &row, keyPath: keyPath, targetTable: targetTable, relation: relationTable.relation.swapped)
    }

    @inlinable
    public func eagerLoadAllColumns<
        Row: IDModel,
        RelationSchema: SchemaProtocol,
        TargetSchema: IDSchemaProtocol,
        FromID: IDType,
        ToID: IDType,
        Decoding: Decodable
    >(
        into rows: inout [Row],
        keyPath: WritableKeyPath<Row, [Decoding]>,
        targetTable: TargetSchema,
        relation: PivotJoinRelation<RelationSchema, FromID, ToID>
    ) async throws
    where Row.Schema.ID == FromID, TargetSchema.ID == ToID
    {
        try await select()
            .column(targetTable.all)
            .from(targetTable)
            .eagerLoad(into: &rows, keyPath: keyPath, toIDColumn: targetTable.id, relation: relation)
    }

    @inlinable
    public func eagerLoadAllColumns<
        Row: IDModel,
        RelationSchema: RelationSchemaProtocol,
        TargetSchema: IDSchemaProtocol,
        Decoding: Decodable
    >(
        into rows: inout [Row],
        keyPath: WritableKeyPath<Row, [Decoding]>,
        targetTable: TargetSchema,
        relationTable: RelationSchema
    ) async throws
    where Row.Schema.ID == RelationSchema.ID1, TargetSchema.ID == RelationSchema.ID2
    {
        try await eagerLoadAllColumns(into: &rows, keyPath: keyPath, targetTable: targetTable, relation: relationTable.relation)
    }

    @inlinable
    public func eagerLoadAllColumns<
        Row: IDModel,
        RelationSchema: RelationSchemaProtocol,
        TargetSchema: IDSchemaProtocol,
        Decoding: Decodable
    >(
        into rows: inout [Row],
        keyPath: WritableKeyPath<Row, [Decoding]>,
        targetTable: TargetSchema,
        relationTable: RelationSchema
    ) async throws
    where Row.Schema.ID == RelationSchema.ID2, TargetSchema.ID == RelationSchema.ID1
    {
        try await eagerLoadAllColumns(into: &rows, keyPath: keyPath, targetTable: targetTable, relation: relationTable.relation.swapped)
    }

    @inlinable
    public func eagerLoadAllColumns<
        Row: IDModel,
        ParentID: IDType,
        Decoding: Decodable,
        ChildSchema: SchemaProtocol
    >(
        into row: inout Row?,
        keyPath: WritableKeyPath<Row, [Decoding]>,
        column: TypedSQLColumn<ChildSchema, ParentID>
    ) async throws where Row.Schema.ID == ParentID {
        try await select()
            .column(SQLLiteral.all)
            .from(ChildSchema.tableName)
            .eagerLoad(into: &row, keyPath: keyPath, column: column)
    }

    @inlinable
    public func eagerLoadAllColumns<
        Row: IDModel,
        ParentID: IDType,
        Decoding: Decodable,
        ChildSchema: SchemaProtocol
    >(
        into rows: inout [Row],
        keyPath: WritableKeyPath<Row, [Decoding]>,
        column: TypedSQLColumn<ChildSchema, ParentID>
    ) async throws where Row.Schema.ID == ParentID {
        try await select()
            .column(SQLLiteral.all)
            .from(ChildSchema.tableName)
            .eagerLoad(into: &rows, keyPath: keyPath, column: column)
    }
}

extension SQLSelectBuilder {
    @inlinable
    public func eagerLoad<
        Row: IDModel,
        RelationSchema: SchemaProtocol,
        ToSchema: IDSchemaProtocol,
        FromID: IDType,
        ToID: IDType,
        Decoding: Decodable
    >(
        into row: inout Row?,
        keyPath: WritableKeyPath<Row, [Decoding]>,
        toIDColumn: TypedSQLColumn<ToSchema, ToID>,
        relation: PivotJoinRelation<RelationSchema, FromID, ToID>
    ) async throws where Row.Schema.ID == FromID {
        guard row != nil else { return }

        let fromColumn = relation.schema[keyPath: relation.from]
        let toColumn = relation.schema[keyPath: relation.to]

        let children = try await self
            .join(relation.schema.tableName, on: toColumn.withTable, .equal, toIDColumn.withTable)
            .where(fromColumn, .equal, row!.id)
            .all(decoding: Decoding.self)

        row![keyPath: keyPath] = children
    }

    @inlinable
    public func eagerLoad<
        Row: IDModel,
        RelationSchema: SchemaProtocol,
        ToSchema: IDSchemaProtocol,
        FromID: IDType,
        ToID: IDType,
        Decoding: Decodable
    >(
        into rows: inout [Row],
        keyPath: WritableKeyPath<Row, [Decoding]>,
        toIDColumn: TypedSQLColumn<ToSchema, ToID>,
        relation: PivotJoinRelation<RelationSchema, FromID, ToID>
    ) async throws where Row.Schema.ID == FromID {
        if rows.isEmpty { return }

        let fromColumn = relation.schema[keyPath: relation.from]
        let toColumn = relation.schema[keyPath: relation.to]

        // IN句でまとめて取得
        let siblings = try await self
            .join(relation.schema.tableName, on: toColumn.withTable, .equal, toIDColumn.withTable)
            .where(fromColumn.withTable, .in, rows.map(\.id))
            .all()

        // idごとに分配
        var map: [FromID: [Decoding]] = [:]
        for sibling in siblings {
            let fromID = try sibling.decode(column: fromColumn.rawValue, as: FromID.self)
            let value = try sibling.decode(model: Decoding.self)
            map[fromID, default: []].append(value)
        }

        for i in rows.indices {
            rows[i][keyPath: keyPath] = map[rows[i].id] ?? []
        }
    }

    @inlinable
    public func eagerLoad<
        Row: IDModel,
        ParentID: IDType,
        Decoding: Decodable,
        ChildSchema: SchemaProtocol
    >(
        into row: inout Row?,
        keyPath: WritableKeyPath<Row, [Decoding]>,
        column: TypedSQLColumn<ChildSchema, ParentID>
    ) async throws where Row.Schema.ID == ParentID {
        guard row != nil else { return }

        let children = try await self
            .where(column, .equal, row!.id)
            .all(decoding: Decoding.self)

        row![keyPath: keyPath] = children
    }

    @inlinable
    public func eagerLoad<
        Row: IDModel,
        ParentID: IDType,
        Decoding: Decodable,
        ChildSchema: SchemaProtocol
    >(
        into rows: inout [Row],
        keyPath: WritableKeyPath<Row, [Decoding]>,
        column: TypedSQLColumn<ChildSchema, ParentID>
    ) async throws where Row.Schema.ID == ParentID {
        if rows.isEmpty { return }

        // IN句でまとめて取得
        let children = try await self
            .where(column, .in, rows.map(\.id))
            .all()

        // idごとに分配
        var map: [ParentID: [Decoding]] = [:]
        for child in children {
            let fromID = try child.decode(column: column.rawValue, as: ParentID.self)
            let value = try child.decode(model: Decoding.self)
            map[fromID, default: []].append(value)
        }

        for i in rows.indices {
            rows[i][keyPath: keyPath] = map[rows[i].id] ?? []
        }
    }
}
