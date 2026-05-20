import Fluent
import Vapor
import struct Foundation.Date

struct StickyNoteDTO: Content {
    var id: UUID?
    var title: String?
    var validSince: Date?
    var validUntil: Date?
    
    func toModel() -> StickyNote {
        let model = StickyNote()
        
        model.id = self.id
        if let title = self.title {
            model.title = title
        }
        if let validSince = self.validSince {
            model.validSince = validSince
        }
        if let validUntil = self.validUntil {
            model.validUntil = validUntil
        }
        return model
    }
}
