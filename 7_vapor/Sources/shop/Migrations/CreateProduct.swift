import Fluent

struct CreateProduct: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("shop")
            .id()
            .field("title", .string, .required)
            .field("price", .uint64, .required)
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema("shop").delete()
    }
}
