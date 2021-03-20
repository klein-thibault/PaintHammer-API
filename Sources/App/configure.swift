import Fluent
import FluentPostgresDriver
import SotoS3
import Vapor

// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    let accessKeyId = Environment.get("AWS_ACCESS_KEY_ID") ?? ""
    let secretAccessKey = Environment.get("AWS_SECRET_ACCESS_KEY") ?? ""
    app.aws.client = AWSClient(credentialProvider: .static(accessKeyId: accessKeyId, secretAccessKey: secretAccessKey),
                               httpClientProvider: .shared(app.http.client.shared))
    app.aws.s3 = S3(client: app.aws.client, region: .useast1)

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

    app.migrations.add(CreatePaint())
    app.migrations.add(CreateProject())
    app.migrations.add(CreateStep())

    // register routes
    try routes(app)
}
