import Fluent
import Vapor

struct ProductController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let products = routes.grouped("products")

        products.get(use: self.index)
        products.post(use: self.create)
        products.group(":productID") { product in
            product.get(use: self.read)
            product.patch(use: self.update)
            product.delete(use: self.delete)
        }
    }

    @Sendable
    func index(req: Request) async throws -> [ProductDTO] {
        try await Product.query(on: req.db).with(\.$categories).all().map { $0.toDTO() }
    }

    @Sendable
    func create(req: Request) async throws -> ProductDTO {
        let dto = try req.content.decode(ProductDTO.self)
        let product = dto.toModel()

        try await product.save(on: req.db)
        if let ids = dto.categoryIDs {
            for cid in ids {
                if let category = try await Category.find(cid, on: req.db) {
                    try await product.$categories.attach(category, on: req.db)
                }
            }
        }

        guard let saved = try await Product.query(on: req.db)
            .filter(\._$id == product.id!)
            .with(\.$categories)
            .first()
        else {
            throw Abort(.internalServerError)
        }

        return saved.toDTO()
    }

    @Sendable
    func read(req: Request) async throws -> ProductDTO {
        guard let productID = req.parameters.get("productID", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        guard let product = try await Product.query(on: req.db)
            .filter(\._$id == productID)
            .with(\.$categories)
            .first()
        else {
            throw Abort(.notFound)
        }
        return product.toDTO()
    }

    @Sendable
    func update(req: Request) async throws -> ProductDTO {
        guard let id = req.parameters.get("productID", as: UUID.self) else { throw Abort(.badRequest) }
        guard let product = try await Product.find(id, on: req.db) else { throw Abort(.notFound) }

        let dto = try req.content.decode(ProductDTO.self)
        // update values
        if let title = dto.title {
            product.title = title
        }
        if let price = dto.price {
            product.price = price
        }

        try await req.db.transaction { db in
            try await product.save(on: db)

            // load existing attached categories
            let existing = try await product.$categories.query(on: db).all()
            let existingIDs = Set(existing.compactMap { $0.id })

            let newIDs = Set(dto.categoryIDs ?? [])

            // detach removed
            for removeID in existingIDs.subtracting(newIDs) {
                if let cat = try await Category.find(removeID, on: db) {
                    try await product.$categories.detach(cat, on: db)
                }
            }

            // attach added
            for addID in newIDs.subtracting(existingIDs) {
                if let cat = try await Category.find(addID, on: db) {
                    try await product.$categories.attach(cat, on: db)
                }
            }
        }

        // return with loaded categories
        guard let saved = try await Product.query(on: req.db).filter(\._$id == product.id!).with(\.$categories).first() else {
            throw Abort(.internalServerError)
        }
        return saved.toDTO()
    }


    @Sendable
    func delete(req: Request) async throws -> HTTPStatus {
        guard let product = try await Product.find(req.parameters.get("productID"), on: req.db) else {
            throw Abort(.notFound)
        }

        try await product.$categories.detachAll(on: req.db)
        try await product.delete(on: req.db)
        return .noContent
    }
}
