import Fluent

struct AddUserToProject: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("projects")
            .field("user_id", .uuid, .required, .references("users", "id"))
            .update()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("projects")
            .deleteField("user_id")
            .update()
    }
}
