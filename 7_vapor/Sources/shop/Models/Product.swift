import Fluent
import struct Foundation.UUID

/// Property wrappers interact poorly with `Sendable` checking, causing a warning for the `@ID` property
/// It is recommended you write your model with sendability checking on and then suppress the warning
/// afterwards with `@unchecked Sendable`.
final class Product: Model, @unchecked Sendable {
    static let schema = "products"
    
    @ID(key: .id)
    var id: UUID?

    @Field(key: "title")
    var title: String

    @Field(key: "price")
    var price: UInt64

    @Siblings(through: ProductCategoryPivot.self, from: \.$product, to: \.$category)
    var categories: [Category]

    init() { }

    init(id: UUID? = nil, title: String, price: UInt64) {
        self.id = id
        self.title = title
        self.price = price
    }
    
    func toDTO() -> ProductDTO {
        .init(
            id: self.id,
            title: self.$title.value,
            price: self.$price.value,
            categoryIDs: {
                let ids = self.categories.compactMap { $0.id }
                return ids.isEmpty ? nil : ids
            }()
        )
    }
}
