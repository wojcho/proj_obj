@testable import shop
import VaporTesting
import Testing
import Fluent
import struct Foundation.Date

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
            let saved = try await Product.query(on: app.db).with(\.$categories).all()
            
            try await app.testing().test(.GET, "products", afterResponse: { res async throws in
                #expect(res.status == .ok)
                #expect(try
                    res.content.decode([ProductDTO].self).sorted(by: { ($0.title ?? "") < ($1.title ?? "") }) ==
                    saved.map { $0.toDTO() }.sorted(by: { ($0.title ?? "") < ($1.title ?? "") })
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
                let models = try await Product.query(on: app.db).with(\.$categories).all()
                #expect(models.map({ $0.toDTO().title }) == [newDTO.title])
            })
        }
    }
    
    @Test("Reading a Product")
    func readProduct() async throws {
        try await withApp { app in
            let product = Product(title: "read-test", price: 1234)
            try await product.create(on: app.db)
            let created = try await Product.query(on: app.db)
                .filter(\._$id == product.id!)
                .with(\.$categories)
                .first()
            #expect(created != nil)

            try await app.testing().test(.GET, "products/\(product.requireID())", afterResponse: { res async throws in
                #expect(res.status == .ok)
                let dto = try res.content.decode(ProductDTO.self)
                #expect(dto == created!.toDTO())
            })
        }
    }

    @Test("Updating a Product")
    func updateProduct() async throws {
        try await withApp { app in
            let product = Product(title: "old-title", price: 1234)
            try await product.create(on: app.db)

            let newTitle = "new-title"
            let newPrice = 5678
            let updateDTO = ProductDTO(id: nil, title: "new-title", price: 5678)
            try await app.testing().test(.PATCH, "products/\(product.requireID())", beforeRequest: { req in
                try req.content.encode(updateDTO)
            }, afterResponse: { res async throws in
                #expect(res.status == .ok)
                let updated = try await Product.query(on: app.db)
                    .filter(\._$id == product.id!)
                    .with(\.$categories)
                    .first()
                #expect(updated != nil)
                let updatedDTO = updated!.toDTO()
                #expect(updatedDTO.title == newTitle)
                #expect(updatedDTO.price! == newPrice)
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

    @Test("Getting all the Categories")
    func getAllCategories() async throws {
        try await withApp { app in
            let p1 = Product(title: "p1", price: 100)
            let p2 = Product(title: "p2", price: 200)
            try await p1.create(on: app.db)
            try await p2.create(on: app.db)

            let c1 = Category(name: "c1")
            let c2 = Category(name: "c2")
            try await c1.create(on: app.db)
            try await c2.create(on: app.db)

            // attach p1 -> c1, p2 -> c2
            try await c1.$products.attach(p1, on: app.db)
            try await c2.$products.attach(p2, on: app.db)

            let saved = try await Category.query(on: app.db).with(\.$products).all()

            try await app.testing().test(.GET, "categories", afterResponse: { res async throws in
                #expect(res.status == .ok)
                #expect(try res.content.decode([CategoryDTO].self).sorted(by: { ($0.name ?? "") < ($1.name ?? "") }) ==
                        saved.map { $0.toDTO() }.sorted(by: { ($0.name ?? "") < ($1.name ?? "") }))
            })
        }
    }

    @Test("Creating a Category with productIDs")
    func createCategoryWithProducts() async throws {
        try await withApp { app in
            let p1 = Product(title: "p-create-1", price: 10)
            let p2 = Product(title: "p-create-2", price: 20)
            try await [p1, p2].create(on: app.db)

            let dto = CategoryDTO(id: nil, name: "new-cat", productIDs: [try p1.requireID(), try p2.requireID()])

            try await app.testing().test(.POST, "categories", beforeRequest: { req in
                try req.content.encode(dto)
            }, afterResponse: { res async throws in
                #expect(res.status == .ok)
                let cats = try await Category.query(on: app.db).with(\.$products).all()
                #expect(cats.count == 1)
                let created = cats[0].toDTO()
                #expect(created.name == dto.name)
                #expect(Set(created.productIDs ?? []) == Set(dto.productIDs!))
            })
        }
    }

    @Test("Reading a Category")
    func readCategory() async throws {
        try await withApp { app in
            let p = Product(title: "p-read", price: 50)
            try await p.create(on: app.db)

            let c = Category(name: "read-cat")
            try await c.create(on: app.db)
            try await c.$products.attach(p, on: app.db)

            let saved = try await Category.query(on: app.db).filter(\._$id == c.id!).with(\.$products).first()
            #expect(saved != nil)

            try await app.testing().test(.GET, "categories/\(c.requireID())", afterResponse: { res async throws in
                #expect(res.status == .ok)
                let dto = try res.content.decode(CategoryDTO.self)
                #expect(dto == saved!.toDTO())
            })
        }
    }

    @Test("Updating a Category properties and product relations")
    func updateCategoryAndBridge() async throws {
        try await withApp { app in
            // prepare products and category
            let p1 = Product(title: "p-old", price: 1)
            let p2 = Product(title: "p-keep", price: 2)
            let p3 = Product(title: "p-add", price: 3)
            try await p1.create(on: app.db)
            try await p2.create(on: app.db)
            try await p3.create(on: app.db)

            let cat = Category(name: "orig-name")
            try await cat.create(on: app.db)

            // attach p1 and p2 initially
            try await cat.$products.attach(p1, on: app.db)
            try await cat.$products.attach(p2, on: app.db)

            // update by replacing in association p1 with p3 and keeping p2
            let updateDTO = CategoryDTO(id: nil, name: "updated-name", productIDs: [try p2.requireID(), try p3.requireID()])

            try await app.testing().test(.PATCH, "categories/\(cat.requireID())", beforeRequest: { req in
                try req.content.encode(updateDTO)
            }, afterResponse: { res async throws in
                #expect(res.status == .ok)
                let reloaded = try await Category.query(on: app.db).filter(\.$id == cat.id!).with(\.$products).first()
                #expect(reloaded != nil)
                let dto = reloaded!.toDTO()
                #expect(dto.name == "updated-name")
                #expect(Set(dto.productIDs ?? []) == Set([try p2.requireID(), try p3.requireID()]))
            })
        }
    }

    @Test("Deleting a Category and detaching bridge entries")
    func deleteCategory() async throws {
        try await withApp { app in
            let p = Product(title: "p-del", price: 5)
            try await p.create(on: app.db)

            let c = Category(name: "c-del")
            try await c.create(on: app.db)
            try await c.$products.attach(p, on: app.db)

            try await app.testing().test(.DELETE, "categories/\(c.requireID())", afterResponse: { res async throws in
                #expect(res.status == .noContent)
                let found = try await Category.find(c.id, on: app.db)
                #expect(found == nil)

                // ensure pivot row removed -> product still exists
                let prod = try await Product.find(p.id, on: app.db)
                #expect(prod != nil)
                let pivots = try await ProductCategoryPivot.query(on: app.db).filter(\.$category.$id == c.id!).all()
                #expect(pivots.isEmpty)
            })
        }
    }

    @Test("Creating a Product which has categoryIDs")
    func createProductWithCategories() async throws {
        try await withApp { app in
            let c1 = Category(name: "cat-create-1")
            let c2 = Category(name: "cat-create-2")
            try await [c1, c2].create(on: app.db)

            let dto = ProductDTO(id: nil, title: "prod-with-cats", price: 999, categoryIDs: [try c1.requireID(), try c2.requireID()])

            try await app.testing().test(.POST, "products", beforeRequest: { req in
                try req.content.encode(dto)
            }, afterResponse: { res async throws in
                #expect(res.status == .ok)
                let prods = try await Product.query(on: app.db).with(\.$categories).all()
                #expect(prods.count == 1)
                let created = prods[0].toDTO()
                #expect(created.title == dto.title)
                #expect(Set(created.categoryIDs ?? []) == Set(dto.categoryIDs!))
            })
        }
    }

    @Test("Updating a categories of a Product through categoryIDs")
    func updateProductBridge() async throws {
        try await withApp { app in
            let cOld = Category(name: "c-old")
            let cKeep = Category(name: "c-keep")
            let cAdd = Category(name: "c-add")
            try await [cOld, cKeep, cAdd].create(on: app.db)

            let prod = Product(title: "prod-update", price: 111)
            try await prod.create(on: app.db)
            try await prod.$categories.attach(cOld, on: app.db)
            try await prod.$categories.attach(cKeep, on: app.db)

            // remove cOld, keep cKeep, add cAdd
            let updateDTO = ProductDTO(id: nil, title: nil, price: nil, categoryIDs: [try cKeep.requireID(), try cAdd.requireID()])

            try await app.testing().test(.PATCH, "products/\(prod.requireID())", beforeRequest: { req in
                try req.content.encode(updateDTO)
            }, afterResponse: { res async throws in
                #expect(res.status == .ok)
                let reloaded = try await Product.query(on: app.db).filter(\._$id == prod.id!).with(\.$categories).first()
                #expect(reloaded != nil)
                let dto = reloaded!.toDTO()
                #expect(Set(dto.categoryIDs ?? []) == Set([try cKeep.requireID(), try cAdd.requireID()]))
            })
        }
    }

    @Test("Create Sticky Note")
    func createStickyNote() async throws {
        let now = Date(timeIntervalSince1970: floor(Date().timeIntervalSince1970))
        let newDTO = StickyNoteDTO(id: nil, title: "test1", validSince: now, validUntil: now.addingTimeInterval(3600))
        
        try await withApp { app in
            try await app.testing().test(.POST, "sticky-notes", beforeRequest: { req in
                try req.content.encode(newDTO)
            }, afterResponse: { res async throws in
                #expect(res.status == .ok)
                let models = try await StickyNote.query(on: app.db).all()
                #expect(models.count == 1)
                let storedDTO = models[0].toDTO()

                #expect(storedDTO.title == newDTO.title)
                #expect(storedDTO.validSince == newDTO.validSince)
                #expect(storedDTO.validUntil == newDTO.validUntil)
            })
        }
    }

    @Test("Read Sticky Note")
    func readStickyNote() async throws {
        try await withApp { app in
            let now = Date(timeIntervalSince1970: floor(Date().timeIntervalSince1970))
            let note = StickyNote(title: "read-note", validSince: now, validUntil: now.addingTimeInterval(3600))
            try await note.create(on: app.db)

            let saved = try await StickyNote.query(on: app.db).filter(\._$id == note.id!).first()
            #expect(saved != nil)

            try await app.testing().test(.GET, "sticky-notes/\(note.requireID())", afterResponse: { res async throws in
                #expect(res.status == .ok)
                let dto = try res.content.decode(StickyNoteDTO.self)
                #expect(dto == saved!.toDTO())
            })
        }
    }

    @Test("Update Sticky Note")
    func updateStickyNote() async throws {
        try await withApp { app in
            let now = Date(timeIntervalSince1970: floor(Date().timeIntervalSince1970))
            let note = StickyNote(title: "old-title", validSince: now, validUntil: now.addingTimeInterval(3600))
            try await note.create(on: app.db)

            let newTitle = "updated-title"
            let newSince = now.addingTimeInterval(10)
            let newUntil = now.addingTimeInterval(7200)
            let updateDTO = StickyNoteDTO(id: nil, title: newTitle, validSince: newSince, validUntil: newUntil)

            try await app.testing().test(.PATCH, "sticky-notes/\(note.requireID())", beforeRequest: { req in
                try req.content.encode(updateDTO)
            }, afterResponse: { res async throws in
                #expect(res.status == .ok)
                let reloaded = try await StickyNote.query(on: app.db).filter(\._$id == note.id!).first()
                #expect(reloaded != nil)
                let dto = reloaded!.toDTO()
                #expect(dto.title == newTitle)
                #expect(dto.validSince == newSince)
                #expect(dto.validUntil == newUntil)
            })
        }
    }

    @Test("Delete Sticky Note")
    func deleteStickyNote() async throws {
        let now = Date(timeIntervalSince1970: floor(Date().timeIntervalSince1970))
        let testStickyNotes = [StickyNote(title: "test1", validSince: now, validUntil: now.addingTimeInterval(3600)), StickyNote(title: "test2", validSince: now, validUntil: now.addingTimeInterval(3600))]
        
        try await withApp { app in
            try await testStickyNotes.create(on: app.db)
            
            try await app.testing().test(.DELETE, "sticky-notes/\(testStickyNotes[0].requireID())", afterResponse: { res async throws in
                #expect(res.status == .noContent)
                let model = try await Product.find(testStickyNotes[0].id, on: app.db)
                #expect(model == nil)
            })
        }
    }

}

extension ProductDTO: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id && lhs.title == rhs.title && lhs.price == rhs.price
    }
}

extension CategoryDTO: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id && lhs.name == rhs.name
    }
}

extension StickyNoteDTO: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
        && lhs.title == rhs.title
        && lhs.validSince == rhs.validSince
        && lhs.validUntil == rhs.validUntil
    }
}
