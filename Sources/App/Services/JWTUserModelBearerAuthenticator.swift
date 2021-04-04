//
//  JWTUserModelBearerAuthenticator.swift
//  
//
//  Created by Thibault Klein on 4/3/21.
//

import JWT
import Vapor

struct JWTUserModelBearerAuthenticator: BearerAuthenticator {
    typealias User = UserModel

    func authenticate(bearer: BearerAuthorization, for request: Request) -> EventLoopFuture<Void> {
        do {
            let jwt = try request.jwt.verify(bearer.token, as: PaintHammerJWT.self)
            let userUUID = UUID(jwt.subject.value)
            return User.find(userUUID, on: request.db)
                .unwrap(orError: Abort(.unauthorized))
                .map { user in
                    request.auth.login(user)
                }
                .transform(to: ())
        }
        catch {
            return request.eventLoop.makeSucceededFuture(())
        }
    }
}
