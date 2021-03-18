import Fluent
import FluentPostgresDriver
import Vapor

// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    if let databaseURL = Environment.get("DATABASE_URL"),
       var postgresConfig = PostgresConfiguration(url: databaseURL) {
        postgresConfig.tlsConfiguration = .forClient(certificateVerification: .none)
        app.databases.use(.postgres(configuration: postgresConfig), as: .psql)
    } else {
        app.databases.use(.postgres(
            hostname: Environment.get("DATABASE_HOST") ?? "localhost",
            port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? PostgresConfiguration.ianaPortNumber,
            username: Environment.get("DATABASE_USERNAME") ?? "thibaultklein",
            password: Environment.get("DATABASE_PASSWORD") ?? "painthammer",
            database: Environment.get("DATABASE_NAME") ?? "painthammer"
        ), as: .psql)
    }

    app.migrations.add(CreateProject())
    app.migrations.add(CreateStep())
    app.migrations.add(CreatePaint())

    // register routes
    try routes(app)
}
