import Fluent
import Foundation

final class ProductCategoryPivot: Model, @unchecked Sendable {
    static let schema = "product-category-pivot"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "product_id")
    var product: Product

    @Parent(key: "category_id")
    var category: Category

    init() {}

    init(id: UUID? = nil, productID: UUID, categoryID: UUID) {
        self.id = id
        self.$product.id = productID
        self.$category.id = categoryID
    }
}
