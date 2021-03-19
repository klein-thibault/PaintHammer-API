import Vapor

enum ImageType: String, Content {
    case project, step
}

struct GenerateUploadImageURLRequest: Content {
    var name: String
    var type: ImageType
    var id: UUID
}
