import Fluent

struct CreatePaint: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("paints")
            .id()
            .field("name", .string, .required)
            .field("brand", .string, .required)
            .field("color", .string, .required)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("paints").delete()
    }
}
