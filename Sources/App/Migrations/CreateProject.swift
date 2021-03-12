import Fluent

struct CreateProject: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("projects")
            .id()
            .field("name", .string, .required)
            .field("image", .string)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("projects").delete()
    }
}
