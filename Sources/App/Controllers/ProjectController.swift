import Fluent
import Vapor

struct ProjectController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let projects = routes.grouped("projects")
        projects.get(use: getProjects)
        projects.get(":projectId", use: getProjectById)
        projects.delete(":projectId", use: deleteProject)
        projects.post(use: createProject)
        projects.post(":projectId", "steps", use: addStepToProject)
        projects.delete(":projectId", "steps", ":stepId", use: deleteStepFromProject)
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

    func addStepToProject(req: Request) throws -> EventLoopFuture<Step> {
        let projectId: UUID = req.parameters.get("projectId")!
        let body = try req.content.decode(CreateStepRequestBody.self)

        return Project.find(projectId, on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { project in
                let step = Step(description: body.description, image: body.image)
                if let paintId = body.paintId {
                    step.$paint.id = UUID(paintId)
                }

                return project.$steps.create(step, on: req.db)
                    .flatMap {
                        let stepId = try! step.requireID()
                        return Step.query(on: req.db)
                            .filter(\.$id == stepId)
                            .with(\.$paint)
                            .first()
                            .unwrap(or: Abort(.internalServerError))
                    }
            }
    }

    func deleteStepFromProject(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let stepId: UUID = req.parameters.get("stepId")!

        return Step.find(stepId, on: req.db)
            .map { $0?.delete(on: req.db) }
            .transform(to: .ok)
    }

    func deleteProject(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let projectId: UUID = req.parameters.get("projectId")!

        return Project.find(projectId, on: req.db)
            .map { $0?.delete(on: req.db) }
            .transform(to: .ok)
    }
}
