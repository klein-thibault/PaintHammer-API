import Fluent
import Vapor

final class Step: Model, Content {
    static let schema = "steps"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "description")
    var description: String

    @Field(key: "image")
    var image: String?

    @OptionalParent(key: "paint_id")
    var paint: Paint?

    @Parent(key: "project_id")
    var project: Project

    init() { }
}
