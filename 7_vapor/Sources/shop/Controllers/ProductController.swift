import Fluent
import Vapor
import Redis

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

        let cacheKey = RedisKey("products:index")

        // try cache first
        if let cached = try await req.redis.get(cacheKey, asJSON: [ProductDTO].self) {
            return cached
        }

        // query database
        let products = try await Product.query(on: req.db)
            .with(\.$categories)
            .all()
            .map { $0.toDTO() }

        // store in cache
        try await req.redis.set(
            cacheKey,
            toJSON: products,
        )

        return products
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

        // invalidate index cache
        _ = try await req.redis.delete(RedisKey("products:index")).get() // https://swiftpackageindex.com/swift-server/redistack/1.6.3/documentation/redistack/redisconnection/delete(_:) https://swiftpackageindex.com/apple/swift-nio/2.79.0/documentation/niocore/eventloopfuture/get() it returns amount of removed keys so it is ok to ignore

        return saved.toDTO()
    }

    func read(req: Request) async throws -> ProductDTO {

        guard let productID = req.parameters.get("productID", as: UUID.self) else {
            throw Abort(.badRequest)
        }

        let cacheKey = RedisKey("products:\(productID)")
        // try read from cache
        if let cached = try await req.redis.get(cacheKey, asJSON: ProductDTO.self) {
            return cached
        }

        guard let product = try await Product.query(on: req.db)
            .filter(\._$id == productID)
            .with(\.$categories)
            .first()
        else {
            throw Abort(.notFound)
        }

        let dto = product.toDTO()

        try await req.redis.set(
            cacheKey,
            toJSON: dto,
        )

        return dto
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

        // invalidate index cache
        _ = try await req.redis.delete(RedisKey("products:index")).get()
        // invalidate individual cache
        _ = try await req.redis.delete(RedisKey("products:\(id)")).get()

        return saved.toDTO()
    }


    @Sendable
    func delete(req: Request) async throws -> HTTPStatus {
        guard let id = req.parameters.get("productID", as: UUID.self) else { throw Abort(.badRequest) }
        guard let product = try await Product.find(id, on: req.db) else {
            throw Abort(.notFound)
        }

        try await product.$categories.detachAll(on: req.db)
        try await product.delete(on: req.db)

        // invalidate index cache
        _ = try await req.redis.delete(RedisKey("products:index")).get()
        // invalidate individual cache
        _ = try await req.redis.delete(RedisKey("products:\(id)")).get()

        return .noContent
    }
}
