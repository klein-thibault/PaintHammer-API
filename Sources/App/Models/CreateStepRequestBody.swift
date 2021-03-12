import Vapor

struct CreateStepRequestBody: Content {
    var description: String
    var image: String?
    var paintId: String?
}
