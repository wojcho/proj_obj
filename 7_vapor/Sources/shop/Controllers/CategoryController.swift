import Fluent
import Vapor

struct CategoryController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let categories = routes.grouped("categories")

        categories.get(use: self.index)
        categories.post(use: self.create)
        categories.group(":categoryID") { category in
            category.get(use: self.read)
            category.patch(use: self.update)
            category.delete(use: self.delete)
        }
    }

    @Sendable
    func index(req: Request) async throws -> [CategoryDTO] {
      try await Category.query(on: req.db).with(\.$products).all().map { $0.toDTO() }
    }

    @Sendable
    func create(req: Request) async throws -> CategoryDTO {
        let dto = try req.content.decode(CategoryDTO.self)
        let category = dto.toModel()

        try await category.save(on: req.db)
        if let ids = dto.productIDs {
            for pid in ids {
                if let product = try await Product.find(pid, on: req.db) {
                    try await category.$products.attach(product, on: req.db)
                }
            }
        }

        guard let saved = try await Category.query(on: req.db)
            .filter(\._$id == category.id!)
            .with(\.$products)
            .first()
        else {
            throw Abort(.internalServerError)
        }

        return saved.toDTO()
    }

    @Sendable
    func read(req: Request) async throws -> CategoryDTO {
        guard let id = req.parameters.get("categoryID", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        guard let category = try await Category.query(on: req.db)
            .filter(\._$id == id)
            .with(\.$products)
            .first()
        else {
            throw Abort(.notFound)
        }
        return category.toDTO()
    }

    @Sendable
    func update(req: Request) async throws -> CategoryDTO {
        guard let id = req.parameters.get("categoryID", as: UUID.self) else { throw Abort(.badRequest) }
        guard let category = try await Category.find(id, on: req.db) else { throw Abort(.notFound) }

        let dto = try req.content.decode(CategoryDTO.self)
        // update values
        if let name = dto.name {
            category.name = name
        }

        try await req.db.transaction { db in
            try await category.save(on: db)

            // load existing attached products
            let existing = try await category.$products.query(on: db).all()
            let existingIDs = Set(existing.compactMap { $0.id })

            let newIDs = Set(dto.productIDs ?? [])

            // detach removed
            for removeID in existingIDs.subtracting(newIDs) {
                if let cat = try await Product.find(removeID, on: db) {
                    try await category.$products.detach(cat, on: db)
                }
            }

            // attach added
            for addID in newIDs.subtracting(existingIDs) {
                if let cat = try await Product.find(addID, on: db) {
                    try await category.$products.attach(cat, on: db)
                }
            }
        }

        // return with loaded categories
        guard let saved = try await Category.query(on: req.db).filter(\._$id == category.id!).with(\.$products).first() else {
            throw Abort(.internalServerError)
        }
        return saved.toDTO()
    }

    @Sendable
    func delete(req: Request) async throws -> HTTPStatus {
        guard let category = try await Category.find(req.parameters.get("categoryID"), on: req.db) else {
            throw Abort(.notFound)
        }

        try await category.$products.detachAll(on: req.db)
        try await category.delete(on: req.db)
        return .noContent
    }
}
