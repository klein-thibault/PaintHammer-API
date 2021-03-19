import Vapor

struct GenerateUploadImageURLRequest: Content {
    var name: String
    var id: UUID
}
