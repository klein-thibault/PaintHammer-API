import Vapor

struct ImageCreationWebhookRequest: Content {
    var filename: String
}
