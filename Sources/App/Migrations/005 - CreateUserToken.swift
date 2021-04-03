import Fluent

struct CreateUserToken: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("tokens")
            .id()
            .field("value", .string, .required)
            .field("user_id", .uuid, .references("users", "id"))
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("tokens").delete()
    }
}
