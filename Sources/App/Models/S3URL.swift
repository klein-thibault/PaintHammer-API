import Vapor

final class S3URL: Content {
    var url: String

    init(url: String) {
        self.url = url
    }
}
