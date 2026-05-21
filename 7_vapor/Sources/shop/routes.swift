import Fluent
import Vapor

struct CategoryEditContext: Encodable {
    let category: CategoryDTO
    let products: [ProductDTO]
}

struct ProductEditContext: Encodable {
    let product: ProductDTO
    let categories: [CategoryDTO]
}

func routes(_ app: Application) throws {
    app.get { req async throws in
        try await req.view.render("index")
    }

    let pc = ProductController()
    let cc = CategoryController()
    let snc = StickyNoteController()

    let categories = app.grouped("categories")
    categories.get { req async throws -> View in
        let apiReq = Request(application: req.application, method: .GET, url: "/api/categories", on: req.eventLoop)
        let content = try await cc.index(req: apiReq)
        return try await req.view.render("Categories/index", [
            "categories": content
        ])
    }
    categories.get("new") { req async throws -> View in
        let apiReq = Request(application: req.application, method: .GET, url: "/api/products", on: req.eventLoop)
        let products = try await pc.index(req: apiReq)
        return try await req.view.render("Categories/new", [
            "products": products
        ])
    }
    categories.get(":id") { req async throws -> View in
        guard let id = req.parameters.get("id", as: String.self) else { throw Abort(.badRequest) }
        let apiReq = Request(application: req.application, method: .GET, url: "/api/categories/\(id)", on: req.eventLoop)
        apiReq.parameters.set("categoryID", to: id)
        let category = try await cc.read(req: apiReq)
        return try await req.view.render("Categories/show", [
            "category": category
        ])
    }
    categories.get(":id", "edit") { req async throws -> View in
        guard let id = req.parameters.get("id", as: String.self) else { throw Abort(.badRequest) }
        let categoryReq = Request(application: req.application, method: .GET, url: "/api/categories/\(id)", on: req.eventLoop)
        categoryReq.parameters.set("categoryID", to: id)
        let category = try await cc.read(req: categoryReq)
        let productsReq = Request(application: req.application, method: .GET, url: "/api/products", on: req.eventLoop)
        let products = try await pc.index(req: productsReq)
        let context = CategoryEditContext(
            category: category,
            products: products
        )
        return try await req.view.render("Categories/edit", context)
    }

    let products = app.grouped("products")
    products.get { req async throws -> View in
        let apiReq = Request(
            application: req.application,
            method: .GET,
            url: "/api/products",
            on: req.eventLoop
        )
        let content = try await pc.index(req: apiReq)
        return try await req.view.render("Products/index", [
            "products": content
        ])
    }

    products.get("new") { req async throws -> View in
        let apiReq = Request(application: req.application, method: .GET, url: "/api/categories", on: req.eventLoop)
        let categories = try await cc.index(req: apiReq)
        return try await req.view.render("Products/new", [
            "categories": categories
        ])
    }

    products.get(":id") { req async throws -> View in
        guard let id = req.parameters.get("id", as: String.self) else { throw Abort(.badRequest) }
        let apiReq = Request(application: req.application, method: .GET, url: "/api/products/\(id)", on: req.eventLoop)
        apiReq.parameters.set("productID", to: id)
        let product = try await pc.read(req: apiReq)
        return try await req.view.render("Products/show", [
            "product": product
        ])
    }

    products.get(":id", "edit") { req async throws -> View in
        guard let id = req.parameters.get("id", as: String.self) else { throw Abort(.badRequest) }
        let productReq = Request(application: req.application, method: .GET, url: "/api/products/\(id)", on: req.eventLoop)
        productReq.parameters.set("productID", to: id)
        let product = try await pc.read(req: productReq)
        let categoriesReq = Request(application: req.application, method: .GET, url: "/api/categories", on: req.eventLoop)
        let categories = try await cc.index(req: categoriesReq)
        let context = ProductEditContext(
            product: product,
            categories: categories
        )
        return try await req.view.render("Products/edit", context)
    }

    let notes = app.grouped("sticky-notes")
    notes.get { req async throws -> View in
        let apiReq = Request(
            application: req.application,
            method: .GET,
            url: "sticky-notes",
            on: req.eventLoop
        )
        let content = try await snc.index(req: apiReq)
        return try await req.view.render("StickyNotes/index", ["stickyNotes": content])
    }
    notes.get("new") { req async throws -> View in
        return try await req.view.render("StickyNotes/new")
    }
    notes.get(":id") { req async throws -> View in
        guard let id = req.parameters.get("id", as: String.self) else { throw Abort(.badRequest) }
        let apiReq = Request(
            application: req.application,
            method: .GET,
            url: URI(string: "/sticky-notes/\(id)"),
            on: req.eventLoop
        )
        apiReq.parameters.set("stickyNoteID", to: id)
        let content = try await snc.read(req: apiReq)
        return try await req.view.render("StickyNotes/show", ["stickyNote": content])
    }
    notes.get(":id", "edit") { req async throws -> View in
        guard let id = req.parameters.get("id", as: String.self) else { throw Abort(.badRequest) }
        let apiReq = Request(
            application: req.application,
            method: .GET,
            url: URI(string: "/sticky-notes/\(id)"),
            on: req.eventLoop
        )
        apiReq.parameters.set("stickyNoteID", to: id)
        let content = try await snc.read(req: apiReq)
        return try await req.view.render("StickyNotes/edit", ["stickyNote": content])
    }

    let api = app.grouped("api")
    try api.register(collection: pc)
    try api.register(collection: cc)
    try api.register(collection: snc)
}
