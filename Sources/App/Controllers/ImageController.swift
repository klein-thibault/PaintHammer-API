import Fluent
import SotoS3
import Vapor

struct ImageController: RouteCollection {
    let bucket = "painthammer"
    let url = "https://painthammer.s3.amazonaws.com"

    func boot(routes: RoutesBuilder) throws {
        let images = routes.grouped("images")
        images.post(use: generateS3UploadURL)
        images.post("new", use: handleNewImageUploadInS3)
    }

    func generateS3UploadURL(req: Request) throws -> EventLoopFuture<S3URL> {
        let body = try req.content.decode(GenerateUploadImageURLRequest.self)

        guard var url = URL(string: url) else {
            throw Abort(.internalServerError)
        }
        url.appendPathComponent(body.type.rawValue)
        url.appendPathComponent(body.id.uuidString)
        url.appendPathComponent(body.name)

        let headers = HTTPHeaders(dictionaryLiteral: ("x-amz-acl", "public-read"))

        let s3 = req.aws.s3
        return s3.signURL(url: url, httpMethod: .PUT, headers: headers, expires: .hours(1))
            // Go back to the request event loop or SwiftNIO will throw an assertion (see https://docs.vapor.codes/4.0/async/#hop)
            .hop(to: req.eventLoop)
            .map { S3URL(url: $0.absoluteString) }
    }

    func handleNewImageUploadInS3(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let body = try req.content.decode(ImageCreationWebhookRequest.self)

        let filename = body.filename.replacingOccurrences(of: "\"", with: "")
        let elements = filename.split(separator: "/")
        guard elements.count == 3 else {
            throw Abort(.internalServerError)
        }

        let imageUrl = url + "/" + filename
        let type = ImageType(rawValue: String(elements[0]))

        switch type {
        case .project:
            let projectId = UUID(String(elements[1]))!
            return Project.query(on: req.db)
                .filter(\.$id == projectId)
                .first()
                .unwrap(or: Abort(.notFound))
                .flatMap { project in
                    project.image = imageUrl
                    return project.update(on: req.db)
                }
                .map { return HTTPStatus.ok }

        case .step:
            let stepId = UUID(String(elements[1]))!
            return Step.query(on: req.db)
                .filter(\.$id == stepId)
                .first()
                .unwrap(or: Abort(.notFound))
                .flatMap { step in
                    step.image = imageUrl
                    return step.update(on: req.db)
                }
                .map { return HTTPStatus.ok }

        default:
            throw Abort(.internalServerError)
        }
    }
}
