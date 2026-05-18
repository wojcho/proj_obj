import Fluent
import Vapor

struct CategoryDTO: Content {
    var id: UUID?
    var name: String?
    var productIDs: [UUID]?
    
    func toModel() -> Category {
        let model = Category()

        model.id = self.id
        if let name = self.name {
            model.name = name
        }
        return model
    }
}
