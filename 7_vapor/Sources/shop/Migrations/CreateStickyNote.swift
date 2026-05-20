import Fluent

struct CreateStickyNote: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("sticky_notes")
            .id()
            .field("title", .string, .required)
            .field("valid_since", .datetime, .required)
            .field("valid_until", .datetime, .required)
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema("sticky_notes").delete()
    }
}
