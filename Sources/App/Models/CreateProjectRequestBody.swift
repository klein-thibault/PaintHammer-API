import Vapor

struct CreateProjectRequestBody: Content {
    var name: String
    var image: String?
}
