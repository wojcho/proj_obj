import NIOSSL
import Fluent
import FluentSQLiteDriver
import Leaf
import Vapor

// configures your application
public func configure(_ app: Application) async throws {

    ContentConfiguration.global.use(
        decoder: URLEncodedFormDecoder(configuration: .init(
            dateDecodingStrategy: .custom { decoder in
                let container = try decoder.singleValueContainer()
                let string = try container.decode(String.self)

                guard let date = ISO8601DateFormatter().date(from: string) else {
                    throw DecodingError.dataCorruptedError(
                        in: container,
                        debugDescription: "Invalid ISO8601 date: '\(string)'"
                    )
                }

                return date
            }
        )),
        for: .urlEncodedForm
    )

    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    app.databases.use(DatabaseConfigurationFactory.sqlite(.file("db.sqlite")), as: .sqlite)

    app.views.use(.leaf)

    app.migrations.add(CreateProduct())
    app.migrations.add(CreateCategory())
    app.migrations.add(CreateProductCategoryPivot())
    app.migrations.add(CreateStickyNote())

    // register routes
    try routes(app)
}
