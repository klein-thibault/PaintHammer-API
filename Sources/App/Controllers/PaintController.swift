import Fluent
import Vapor

struct PaintController: RouteCollection {
    var paintURLs = [
        URI("https://www.scalemates.com/colors/citadel--672"),
        URI("https://www.scalemates.com/colors/scale75--683")
    ]

    func boot(routes: RoutesBuilder) throws {
        let paints = routes.grouped("paints")
        paints.get(use: getPaints)
        paints.get("brands", use: getPaintBrands)
        paints.post("seed", use: storePaints)
    }

    func getPaints(req: Request) throws -> EventLoopFuture<[Paint]> {
        if let brand = try? req.query.decode(GetPaintsQuery.self).brand {
            return Paint.query(on: req.db)
                .filter(\.$brand == brand)
                .all()
        } else {
            return Paint.query(on: req.db).all()
        }
    }

    func getPaintBrands(req: Request) throws -> EventLoopFuture<[String]> {
        return Paint.query(on: req.db)
            .all(\.$brand)
            .map { brands in
                let set = Set(brands)
                return Array(set)
            }
    }

    func storePaints(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let queue = EventLoopFutureQueue(eventLoop: req.eventLoop)
        return paintURLs.map { url in
            queue.append(downloadAndStorePaints(req: req, url: url))
        }
        .flatten(on: req.eventLoop)
        .transform(to: .ok)
    }

    private func downloadAndStorePaints(req: Request, url: URI) -> EventLoopFuture<[Paint]> {
        return req.client.get(url)
            .flatMapThrowing { response -> ByteBuffer in
                guard let body = response.body else {
                    throw Abort(.internalServerError)
                }

                return body
            }
            .map { body -> [Paint] in
                let html = String(decoding: body.readableBytesView, as: UTF8.self)
                let paints = PaintHTMLParser().parseHTML(html)
                return paints
            }
            .flatMap { paints in
                return paints.create(on: req.db).map { paints }
            }
    }
}
