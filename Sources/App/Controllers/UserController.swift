import Fluent
import JWT
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
                return UserModel(email: body.email, password: digest)
                    .save(on: req.db)
            }
            .transform(to: .ok)
    }

    func login(req: Request) throws -> EventLoopFuture<UserToken> {
        let body = try req.content.decode(CreateUserRequestBody.self)

        return UserModel.query(on: req.db)
            .filter(\.$email == body.email)
            .first()
            .unwrap(orError: Abort(.notFound))
            .flatMap { user in
                return req.password.async.verify(body.password, created: user.password)
                    .flatMapThrowing{ isValid in
                        guard isValid else {
                            throw Abort(.notFound)
                        }

                        let jwt = PaintHammerJWT(subject: SubjectClaim(value: user.id!.uuidString),
                                                 expiration: .init(value: .distantFuture),
                                                 isAdmin: true)
                        let signedJWT = try req.jwt.sign(jwt)
                        return UserToken(token: signedJWT)
                    }
            }
    }
}
