import SQLKit

// MARK: - Parent

extension SQLDatabase {
    @inlinable
    public func eagerLoadAllColumns<
        Row: Identifiable,
        RowSchema: IDSchemaProtocol,
        ParentSchema: IDSchemaProtocol,
        Parent: Decodable & Identifiable
    >(
        into row: inout Row?,
        keyPath: WritableKeyPath<Row, Parent?>,
        parentIDColumn: TypedSQLColumn<RowSchema, Parent.ID>,
        parentSchema: ParentSchema.Type
    ) async throws where  Row.ID == RowSchema.ID, Parent.ID == ParentSchema.ID {
        try await select()
            .column(SQLLiteral.all)
            .from(ParentSchema.tableName)
            .eagerLoad(into: &row, keyPath: keyPath, parentIDColumn: parentIDColumn)
    }

    @inlinable
    public func eagerLoadAllColumns<
        Row: Identifiable,
        RowSchema: IDSchemaProtocol,
        ParentSchema: IDSchemaProtocol,
        Parent: Decodable & Identifiable
    >(
        into rows: inout [Row],
        keyPath: WritableKeyPath<Row, Parent?>,
        parentIDColumn: TypedSQLColumn<RowSchema, Parent.ID>,
        parentSchema: ParentSchema.Type
    ) async throws where  Row.ID == RowSchema.ID, Parent.ID == ParentSchema.ID  {
        try await select()
            .column(SQLLiteral.all)
            .from(ParentSchema.tableName)
            .eagerLoad(into: &rows, keyPath: keyPath, parentIDColumn: parentIDColumn)
    }
}

extension SQLSelectBuilder {
    @inlinable
    public func eagerLoad<
        Row: Identifiable,
        RowSchema: IDSchemaProtocol,
        Parent: Decodable & Identifiable
    >(
        into row: inout Row?,
        keyPath: WritableKeyPath<Row, Parent?>,
        parentIDColumn: TypedSQLColumn<RowSchema, Parent.ID>
    ) async throws where Row.ID == RowSchema.ID {
        guard row != nil else { return }

        let parent = try await self
            .where("id", .equal, database.select()
                .column(parentIDColumn)
                .from(RowSchema.self)
                .where(RowSchema.id, .equal, row!.id)
                .query
            )
            .first(decoding: Parent.self)

        row![keyPath: keyPath] = parent
    }

    @inlinable
    public func eagerLoad<
        Row: Identifiable,
        RowSchema: IDSchemaProtocol,
        Parent: Decodable & Identifiable
    >(
        into rows: inout [Row],
        keyPath: WritableKeyPath<Row, Parent?>,
        parentIDColumn: TypedSQLColumn<RowSchema, Parent.ID>
    ) async throws where Row.ID == RowSchema.ID {
        if rows.isEmpty { return }

        // IN句でまとめて取得
        let parents = try await self
            .column(RowSchema.id.withTable, as: "_row_id")
            .where("id", .in, database.select()
                .column(parentIDColumn)
                .from(RowSchema.self)
                .where(RowSchema.id, .in, rows.map(\.id))
                .query
            )
            .all()

        // idごとに分配
        var map: [Row.ID: Parent] = [:]
        for parent in parents {
            let toID = try parent.decode(column: "_row_id", as: Row.ID.self)
            let value = try parent.decode(model: Parent.self)
            map[toID] = value
        }

        for i in rows.indices {
            rows[i][keyPath: keyPath] = map[rows[i].id]
        }
    }
}

// MARK: - Children

extension SQLDatabase {
    @inlinable
    public func eagerLoadAllColumns<
        Row: Identifiable,
        ChildrenSchema: SchemaProtocol
    >(
        into row: inout Row?,
        keyPath: WritableKeyPath<Row, [some Decodable]>,
        column: TypedSQLColumn<ChildrenSchema, Row.ID>
    ) async throws where Row.ID: Encodable {
        try await select()
            .column(SQLLiteral.all)
            .from(ChildrenSchema.tableName)
            .eagerLoad(into: &row, keyPath: keyPath, column: column)
    }

    @inlinable
    public func eagerLoadAllColumns<
        Row: Identifiable,
        ChildrenSchema: SchemaProtocol
    >(
        into rows: inout [Row],
        keyPath: WritableKeyPath<Row, [some Decodable]>,
        column: TypedSQLColumn<ChildrenSchema, Row.ID>
    ) async throws where Row.ID: Codable {
        try await select()
            .column(SQLLiteral.all)
            .from(ChildrenSchema.tableName)
            .eagerLoad(into: &rows, keyPath: keyPath, column: column)
    }
}

extension SQLSelectBuilder {
    @inlinable
    public func eagerLoad<
        Row: Identifiable,
        Child: Decodable
    >(
        into row: inout Row?,
        keyPath: WritableKeyPath<Row, [Child]>,
        column: TypedSQLColumn<some SchemaProtocol, Row.ID>
    ) async throws where Row.ID: Encodable {
        guard row != nil else { return }

        let children = try await self
            .where(column, .equal, row!.id)
            .all(decoding: Child.self)

        row![keyPath: keyPath] = children
    }

    @inlinable
    public func eagerLoad<
        Row: Identifiable,
        Child: Decodable
    >(
        into rows: inout [Row],
        keyPath: WritableKeyPath<Row, [Child]>,
        column: TypedSQLColumn<some SchemaProtocol, Row.ID>
    ) async throws where Row.ID: Codable {
        if rows.isEmpty { return }

        // IN句でまとめて取得
        let children = try await self
            .where(column, .in, rows.map(\.id))
            .all()

        // idごとに分配
        var map: [Row.ID: [Child]] = [:]
        for child in children {
            let fromID = try child.decode(column: column.name, as: Row.ID.self)
            let value = try child.decode(model: Child.self)
            map[fromID, default: []].append(value)
        }

        for i in rows.indices {
            rows[i][keyPath: keyPath] = map[rows[i].id] ?? []
        }
    }
}

// MARK: - Pivot join

extension SQLDatabase {
    @inlinable
    public func eagerLoadAllColumns<
        Row: Identifiable,
        TargetSchema: IDSchemaProtocol,
        FromID: IDType,
        ToID: IDType,
        Decoding: Decodable
    >(
        into row: inout Row?,
        keyPath: WritableKeyPath<Row, [Decoding]>,
        targetTable: TargetSchema.Type,
        relation: PivotJoinRelation<some SchemaProtocol, FromID, ToID>
    ) async throws
    where Row.ID == FromID, TargetSchema.ID == ToID
    {
        try await select()
            .column(SQLLiteral.all)
            .from(targetTable)
            .eagerLoad(into: &row, keyPath: keyPath, toIDColumn: TargetSchema.id, relation: relation)
    }

    @inlinable
    public func eagerLoadAllColumns<
        Row: Identifiable,
        RelationSchema: RelationSchemaProtocol,
        TargetSchema: IDSchemaProtocol,
        Decoding: Decodable
    >(
        into row: inout Row?,
        keyPath: WritableKeyPath<Row, [Decoding]>,
        targetTable: TargetSchema.Type,
        relationTable: RelationSchema.Type
    ) async throws
    where Row.ID == RelationSchema.ID1, TargetSchema.ID == RelationSchema.ID2
    {
        try await eagerLoadAllColumns(into: &row, keyPath: keyPath, targetTable: targetTable, relation: RelationSchema.relation)
    }

    @inlinable
    public func eagerLoadAllColumns<
        Row: Identifiable,
        RelationSchema: RelationSchemaProtocol,
        TargetSchema: IDSchemaProtocol,
        Decoding: Decodable
    >(
        into row: inout Row?,
        keyPath: WritableKeyPath<Row, [Decoding]>,
        targetTable: TargetSchema.Type,
        relationTable: RelationSchema.Type
    ) async throws
    where Row.ID == RelationSchema.ID2, TargetSchema.ID == RelationSchema.ID1
    {
        try await eagerLoadAllColumns(into: &row, keyPath: keyPath, targetTable: targetTable, relation: RelationSchema.relation.swapped)
    }

    @inlinable
    public func eagerLoadAllColumns<
        Row: Identifiable,
        TargetSchema: IDSchemaProtocol,
        FromID: IDType,
        ToID: IDType,
        Decoding: Decodable
    >(
        into rows: inout [Row],
        keyPath: WritableKeyPath<Row, [Decoding]>,
        targetTable: TargetSchema.Type,
        relation: PivotJoinRelation<some SchemaProtocol, FromID, ToID>
    ) async throws
    where Row.ID == FromID, TargetSchema.ID == ToID
    {
        try await select()
            .column(SQLLiteral.all)
            .from(targetTable)
            .eagerLoad(into: &rows, keyPath: keyPath, toIDColumn: TargetSchema.id, relation: relation)
    }

    @inlinable
    public func eagerLoadAllColumns<
        Row: Identifiable,
        RelationSchema: RelationSchemaProtocol,
        TargetSchema: IDSchemaProtocol,
        Decoding: Decodable
    >(
        into rows: inout [Row],
        keyPath: WritableKeyPath<Row, [Decoding]>,
        targetTable: TargetSchema.Type,
        relationTable: RelationSchema.Type
    ) async throws
    where Row.ID == RelationSchema.ID1, TargetSchema.ID == RelationSchema.ID2
    {
        try await eagerLoadAllColumns(into: &rows, keyPath: keyPath, targetTable: targetTable, relation: RelationSchema.relation)
    }

    @inlinable
    public func eagerLoadAllColumns<
        Row: Identifiable,
        RelationSchema: RelationSchemaProtocol,
        TargetSchema: IDSchemaProtocol
    >(
        into rows: inout [Row],
        keyPath: WritableKeyPath<Row, [some Decodable]>,
        targetTable: TargetSchema.Type,
        relationTable: RelationSchema.Type
    ) async throws
    where Row.ID == RelationSchema.ID2, TargetSchema.ID == RelationSchema.ID1
    {
        try await eagerLoadAllColumns(into: &rows, keyPath: keyPath, targetTable: targetTable, relation: RelationSchema.relation.swapped)
    }
}

extension SQLSelectBuilder {
    @inlinable
    public func eagerLoad<
        Row: Identifiable,
        RelationSchema: SchemaProtocol,
        FromID: IDType,
        ToID: IDType,
        Decoding: Decodable
    >(
        into row: inout Row?,
        keyPath: WritableKeyPath<Row, [Decoding]>,
        toIDColumn: TypedSQLColumn<some IDSchemaProtocol, ToID>,
        relation: PivotJoinRelation<RelationSchema, FromID, ToID>
    ) async throws where Row.ID == FromID {
        guard row != nil else { return }

        let children = try await self
            .join(RelationSchema.tableName, on: relation.to.withTable, .equal, toIDColumn.withTable)
            .where(relation.from, .equal, row!.id)
            .all(decoding: Decoding.self)

        row![keyPath: keyPath] = children
    }

    @inlinable
    public func eagerLoad<
        Row: Identifiable,
        RelationSchema: SchemaProtocol,
        FromID: IDType,
        ToID: IDType,
        Decoding: Decodable
    >(
        into rows: inout [Row],
        keyPath: WritableKeyPath<Row, [Decoding]>,
        toIDColumn: TypedSQLColumn<some IDSchemaProtocol, ToID>,
        relation: PivotJoinRelation<RelationSchema, FromID, ToID>
    ) async throws where Row.ID == FromID {
        if rows.isEmpty { return }

        // IN句でまとめて取得
        let siblings = try await self
            .join(RelationSchema.tableName, on: relation.to.withTable, .equal, toIDColumn.withTable)
            .where(relation.from.withTable, .in, rows.map(\.id))
            .all()

        // idごとに分配
        var map: [FromID: [Decoding]] = [:]
        for sibling in siblings {
            let fromID = try sibling.decode(column: relation.from.name, as: FromID.self)
            let value = try sibling.decode(model: Decoding.self)
            map[fromID, default: []].append(value)
        }

        for i in rows.indices {
            rows[i][keyPath: keyPath] = map[rows[i].id] ?? []
        }
    }
}
