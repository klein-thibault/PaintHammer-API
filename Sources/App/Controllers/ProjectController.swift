import Fluent
import Vapor

struct ProjectController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let projects = routes.grouped("projects")
        projects.get(use: getProjects)
        projects.get(":projectId", use: getProjectById)
        projects.post(use: createProject)
        projects.post(":projectId", "steps", use: addStepToProject)
    }

    func getProjects(req: Request) throws -> EventLoopFuture<[Project]> {
        return Project.query(on: req.db)
            .with(\.$steps) { step in
                step.with(\.$paint)
            }
            .all()
    }

    func getProjectById(req: Request) throws -> EventLoopFuture<Project> {
        let projectId: UUID = req.parameters.get("projectId")!

        return Project.find(projectId, on: req.db)
            .unwrap(or: Abort(.notFound))
    }

    func createProject(req: Request) throws -> EventLoopFuture<Project> {
        let body = try req.content.decode(CreateProjectRequestBody.self)
        let project = Project(name: body.name, image: body.image)
        return project.create(on: req.db).map { project }
    }

    func addStepToProject(req: Request) throws -> EventLoopFuture<Project> {
        let projectId: UUID = req.parameters.get("projectId")!
        let body = try req.content.decode(CreateStepRequestBody.self)

        return Project.find(projectId, on: req.db)
            .flatMapThrowing { project -> Project in
                guard let project = project else {
                    throw Abort(.notFound)
                }

                return project
            }
            .flatMap { project in
                let step = Step(description: body.description, image: body.image)
                if let paintId = body.paintId {
                    step.$paint.id = UUID(paintId)
                }
                return project.$steps.create(step, on: req.db).map { project }
            }
    }
}
