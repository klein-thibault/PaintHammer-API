import Fluent
import Vapor

struct ProjectController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let projects = routes.grouped("projects")
        projects.get(use: getProjects)
        projects.get(":projectId", use: getProjectById)
        projects.post(use: createProject)
    }

    func getProjects(req: Request) throws -> EventLoopFuture<[Project]> {
        return Project.query(on: req.db).all()
    }

    func getProjectById(req: Request) throws -> EventLoopFuture<Project> {
        let projectId: UUID = req.parameters.get("projectId")!

        return Project.find(projectId, on: req.db)
            .flatMapThrowing { project in
                guard let project = project else {
                    throw Abort(.notFound)
                }

                return project
            }
    }

    func createProject(req: Request) throws -> EventLoopFuture<Project> {
        let body = try req.content.decode(CreateProjectRequestBody.self)
        let project = Project(name: body.name, image: body.image)
        return project.create(on: req.db).map { project }
    }
}
