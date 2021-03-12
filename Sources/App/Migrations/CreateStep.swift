import Fluent

struct CreateStep: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("steps")
            .id()
            .field("description", .string, .required)
            .field("image", .string)
            .field("paint_id", .uuid, .references("paints", "id"))
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("steps").delete()
    }
}
