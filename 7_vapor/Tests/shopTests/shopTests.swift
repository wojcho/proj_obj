@testable import shop
import VaporTesting
import Testing
import Fluent

@Suite("App Tests with DB", .serialized)
struct shopTests {
    private func withApp(_ test: (Application) async throws -> ()) async throws {
        let app = try await Application.make(.testing)
        do {
            try await configure(app)
            try await app.autoMigrate()
            try await test(app)
            try await app.autoRevert()
        } catch {
            try? await app.autoRevert()
            try await app.asyncShutdown()
            throw error
        }
        try await app.asyncShutdown()
    }
    
    @Test("Getting all the Products")
    func getAllProducts() async throws {
        try await withApp { app in
            let sampleProducts = [Product(title: "sample1", price: 100), Product(title: "sample2", price: 400)]
            try await sampleProducts.create(on: app.db)
            
            try await app.testing().test(.GET, "products", afterResponse: { res async throws in
                #expect(res.status == .ok)
                #expect(try
                    res.content.decode([ProductDTO].self).sorted(by: { ($0.title ?? "") < ($1.title ?? "") }) ==
                    sampleProducts.map { $0.toDTO() }.sorted(by: { ($0.title ?? "") < ($1.title ?? "") })
                )
            })
        }
    }
    
    @Test("Creating a Product")
    func createProduct() async throws {
        let newDTO = ProductDTO(id: nil, title: "test", price: 1234)
        
        try await withApp { app in
            try await app.testing().test(.POST, "products", beforeRequest: { req in
                try req.content.encode(newDTO)
            }, afterResponse: { res async throws in
                #expect(res.status == .ok)
                let models = try await Product.query(on: app.db).all()
                #expect(models.map({ $0.toDTO().title }) == [newDTO.title])
            })
        }
    }
    
    @Test("Reading a Product")
    func readProduct() async throws {
        try await withApp { app in
            let product = Product(title: "read-test", price: 1234)
            try await product.create(on: app.db)

            try await app.testing().test(.GET, "products/\(product.requireID())", afterResponse: { res async throws in
                #expect(res.status == .ok)
                let dto = try res.content.decode(ProductDTO.self)
                #expect(dto == product.toDTO())
            })
        }
    }

    @Test("Updating a Product")
    func updateProduct() async throws {
        try await withApp { app in
            let product = Product(title: "old-title", price: 1234)
            try await product.create(on: app.db)

            let updateDTO = ProductDTO(id: nil, title: "new-title", price: 5678)
            try await app.testing().test(.PATCH, "products/\(product.requireID())", beforeRequest: { req in
                try req.content.encode(updateDTO)
            }, afterResponse: { res async throws in
                #expect(res.status == .ok)
                let updated = try await Product.find(product.id, on: app.db)
                #expect(updated != nil)
                #expect(updated!.toDTO().title == updateDTO.title)
            })
        }
    }

    @Test("Deleting a Product")
    func deleteProduct() async throws {
        let testProducts = [Product(title: "test1", price: 1234), Product(title: "test2", price: 1234)]
        
        try await withApp { app in
            try await testProducts.create(on: app.db)
            
            try await app.testing().test(.DELETE, "products/\(testProducts[0].requireID())", afterResponse: { res async throws in
                #expect(res.status == .noContent)
                let model = try await Product.find(testProducts[0].id, on: app.db)
                #expect(model == nil)
            })
        }
    }
}

extension ProductDTO: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id && lhs.title == rhs.title
    }
}
