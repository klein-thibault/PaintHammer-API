//
//  PaintController.swift
//  
//
//  Created by Thibault Klein on 3/4/21.
//

import Fluent
import Vapor

struct PaintController: RouteCollection {
    var paintURLs = ["https://www.scalemates.com/colors/citadel--672"]

    func boot(routes: RoutesBuilder) throws {
        let paints = routes.grouped("paints")
        paints.get(use: getPaints)
        paints.get("test") { req in
            return "It works!"
        }
        paints.post("seed", use: storePaints)
    }

    func getPaints(req: Request) throws -> EventLoopFuture<[Paint]> {
        if let brand = req.parameters.get("brand") {
            return Paint.query(on: req.db)
                .filter(\.$brand == brand)
                .all()
        }

        return Paint.query(on: req.db).all()
    }

    func storePaints(req: Request) throws -> EventLoopFuture<[Paint]> {
        let url = URI(string: "https://www.scalemates.com/colors/citadel--672")
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
