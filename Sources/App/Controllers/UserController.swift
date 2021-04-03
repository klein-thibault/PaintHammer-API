import Fluent
import Vapor

struct UserController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let users = routes.grouped("auth")
        users.post("create", use: createUser)
        users.post("login", use: login)
    }

    func createUser(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let body = try req.content.decode(CreateUserRequestBody.self)

        return req.password.async.hash(body.password)
            .flatMap { digest in
                return User(email: body.email, password: digest)
                    .save(on: req.db)
            }
            .transform(to: .ok)
    }

    func login(req: Request) throws -> EventLoopFuture<UserToken> {
        let body = try req.content.decode(CreateUserRequestBody.self)

        return User.query(on: req.db)
            .filter(\.$email == body.email)
            .first()
            .unwrap(orError: Abort(.notFound))
            .flatMap { user in
                return req.password.async.verify(body.password, created: user.password)
                    .flatMapThrowing{ isValid -> Bool in
                        guard isValid else {
                            throw Abort(.notFound)
                        }

                        return isValid
                    }
                    .flatMap { _ -> EventLoopFuture<UserToken> in
                        return UserToken.query(on: req.db)
                            .filter(\.$user.$id == user.id!)
                            .first()
                            .flatMap { token in
                                if let token = token {
                                    return req.eventLoop.makeSucceededFuture(token)
                                } else {
                                    let newToken = UserToken(value: UUID().uuidString, userId: user.id!)
                                    return newToken
                                        .create(on: req.db)
                                        .map { _ in newToken }
                                }
                            }
                    }
            }
    }
}
