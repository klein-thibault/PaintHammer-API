//
//  PaintController.swift
//  
//
//  Created by Thibault Klein on 3/4/21.
//

import Fluent
import Vapor

struct PaintController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let paints = routes.grouped("paints")
        paints.get(use: getPaints)
    }

    func getPaints(req: Request) throws -> EventLoopFuture<[Paint]> {
        let url = URI(string: "https://www.scalemates.com/colors/citadel--672")
        return req.client.get(url)
            .flatMapThrowing { response in
                guard let body = response.body else {
                    throw Abort(.internalServerError)
                }

                let html = String(decoding: body.readableBytesView, as: UTF8.self)
                let paints = PaintHTMLParser().parseHTML(html)
                return paints
            }
    }
}
