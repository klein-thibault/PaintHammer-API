import Fluent
import Vapor

final class Project: Model, Content {
    static let schema = "projects"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    @Field(key: "image")
    var image: String?

    @Children(for: \.$project)
    var steps: [Step]

    @Parent(key: "user_id")
    var user: UserModel

    init() { }

    init(name: String, image: String?) {
        self.name = name
        self.image = image
    }
}
