import SQLKitTyping

func example1(sql: some SQLDatabase) async throws {
    let rows = try await sql.selectWithColumns {
        TrackTable.TrackId
        TrackTable.Name
        TrackTable.Composer
        TrackTable.UnitPrice
    }
    .from(TrackTable.self)
    .all()
    for row in rows[..<5] {
        print(row.TrackId, row.Name, row.Composer ?? "null", row.UnitPrice)
    }
}

func example2(sql: some SQLDatabase) async throws {
    let rows = try await sql.selectWithColumn(TrackTable.all)
        .from(TrackTable.self)
        .all()
    for row in rows[..<5] {
        print(row.TrackId, row.Name, row.Composer ?? "null", row.UnitPrice)
    }
}

func example3(sql: some SQLDatabase) async throws {
    let rows = try await sql.selectWithColumns {
        TrackTable.TrackId
        TrackTable.Name
        AlbumTable.Title
    }
        .from(TrackTable.self)
        .join(AlbumTable.self, on: TrackTable.AlbumId, .equal, AlbumTable.AlbumId)
        .all()
    for row in rows[..<5] {
        print(row.TrackId, row.Name, row.Title)
    }
}

func example4(sql: some SQLDatabase) async throws {
    let rows = try await sql.selectWithColumns {
        group1 {
            TrackTable.TrackId
            TrackTable.Name
            TrackTable.AlbumId
        }
        group2 {
            AlbumTable.AlbumId
            AlbumTable.Title
        }
    }
        .from(TrackTable.self)
        .join(AlbumTable.self, on: TrackTable.AlbumId, .equal, AlbumTable.AlbumId)
        .all()
    for row in rows[..<5] {
        print(row.group1.TrackId, row.group1.Name, row.group1.AlbumId ?? "null", row.group2.AlbumId, row.group2.Title)
    }
}

func example5(sql: some SQLDatabase) async throws {
    let rows = try await sql.selectWithColumns {
        TrackTable.TrackId
        TrackTable.Name
        AlbumTable.Title
        group1 {
            ArtistTable.Name
        }
    }
        .from(TrackTable.self)
        .join(AlbumTable.self, on: TrackTable.AlbumId, .equal, AlbumTable.AlbumId)
        .join(ArtistTable.self, on: AlbumTable.ArtistId, .equal, ArtistTable.ArtistId)
        .where(ArtistTable.ArtistId.withTable, .equal, 10)
        .all()
    for row in rows[..<5] {
        print(row.TrackId, row.Name, row.Title, row.group1.Name)
    }
}

func example6(sql: some SQLDatabase) async throws {
    let rows = try await sql.selectWithColumns {
        ArtistTable.ArtistId
        AlbumTable.AlbumId.nullable
    }
        .from(ArtistTable.self)
        .join(AlbumTable.self, method: SQLJoinMethod.left,
              on: ArtistTable.ArtistId, .equal, AlbumTable.ArtistId)
        .all()
    for row in rows[..<60] {
        print(row.ArtistId, row.AlbumId ?? "null")
    }
}

enum Custom {
    #SQLColumnPropertyType(name: "Manager")
    #SQLColumnPropertyType(name: "DirectReport")
}

func example7(sql: some SQLDatabase) async throws {
    let rows = try await sql.selectWithColumns {
        Custom.Manager(SQLQueryString("m.firstname || ' ' || m.lastname"), as: String.self)
        Custom.DirectReport(SQLQueryString("e.firstname || ' ' || e.lastname"), as: String.self)
    }
        .from(EmployeeTable.tableName, as: "e")
        .join(SQLAlias(EmployeeTable.tableName, as: "m"), method: SQLJoinMethod.inner,
              on: SQLColumn(EmployeeTable.EmployeeId.name, table: "m"), .equal, SQLColumn(EmployeeTable.ReportsTo.name, table: "e"))
        .orderBy(SQLColumn("Manager"))
        .all()
    for row in rows[..<5] {
        print(row.Manager, row.DirectReport)
    }
}

extension Custom {
    #SQLColumnPropertyType(name: "avg")
}

func example8(sql: some SQLDatabase) async throws { 
    let row = try await sql.selectWithColumn(
        Custom.avg(SQLColumn("size", table: "album"), as: Double.self)
    )
        .from(
            SQLGroupExpression(sql.select()
                .column(SQLFunction("SUM", args: TrackTable.Bytes), as: "size")
                .from(TrackTable.self)
                .groupBy(TrackTable.AlbumId)
                .query),
            as: SQLIdentifier("album")
        )
        .first()

    print(row?.avg ?? "null")
}

func example9(sql: some SQLDatabase) async throws {
    let rows = try await sql.insert(into: ArtistTable.tableName)
        .columnsAndValues(
            columns: ArtistTable.Name,
            values: ["Buddy Rich", "Candido", "Charlie Byrd"]
        )
        .returningWithColumn(ArtistTable.all)
        .all()

    for row in rows {
        print(row.ArtistId, row.Name)
    }
}
