import Fluent
import struct Foundation.UUID
import struct Foundation.Date

final class StickyNote: Model, @unchecked Sendable {
    static let schema = "sticky_notes"
    
    @ID(key: .id)
    var id: UUID?

    @Field(key: "title")
    var title: String

    @Field(key: "valid_since")
    var validSince: Date

    @Field(key: "valid_until")
    var validUntil: Date?

    init() { }

    init(id: UUID? = nil, title: String, validSince: Date, validUntil: Date?) {
        self.id = id
        self.title = title
        self.validSince = validSince
        self.validUntil = validUntil
    }
    
    func toDTO() -> StickyNoteDTO {
        .init(
            id: self.id,
            title: self.$title.value,
            validSince: self.$validSince.value,
            validUntil: self.validUntil,
        )
    }
}
