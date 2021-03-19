import Fluent
import SotoS3
import Vapor

struct ImageController: RouteCollection {
    let bucket = "painthammer"
    let url = "https://painthammer.s3.amazonaws.com"

    func boot(routes: RoutesBuilder) throws {
        let images = routes.grouped("images")
        images.post(use: generateS3UploadURL)
    }

    func generateS3UploadURL(req: Request) throws -> EventLoopFuture<S3URL> {
        let body = try req.content.decode(GenerateUploadImageURLRequest.self)

        guard var url = URL(string: url) else {
            throw Abort(.internalServerError)
        }
        url.appendPathComponent(body.id.uuidString)
        url.appendPathComponent(body.name)

        let headers = HTTPHeaders(dictionaryLiteral: ("x-amz-acl", "public-read"))

        let s3 = req.aws.s3
        return s3.signURL(url: url, httpMethod: .PUT, headers: headers, expires: .hours(1))
            // Go back to the request event loop or SwiftNIO will throw an assertion (see https://docs.vapor.codes/4.0/async/#hop)
            .hop(to: req.eventLoop)
            .map { S3URL(url: $0.absoluteString) }
    }
}
