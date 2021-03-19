import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { req in
        return "It works!"
    }

    try app.register(collection: PaintController())
    try app.register(collection: ProjectController())
    try app.register(collection: ImageController())
}
