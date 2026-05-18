import Fluent

struct CreateProductCategoryPivot: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("product-category-pivot")
            .id()
            .field("product_id", .uuid, .required, .references("products", "id"))
            .field("category_id", .uuid, .required, .references("categories", "id"))
            .unique(on: "product_id", "category_id")
            .create()
    }
    func revert(on database: any Database) async throws {
        try await database.schema("product-category-pivot").delete()
    }
}
