import Fluent
import Vapor

struct StickyNoteController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let stickyNotes = routes.grouped("sticky-notes")

        stickyNotes.get(use: self.index)
        stickyNotes.post(use: self.create)
        stickyNotes.group(":stickyNoteID") { stickyNote in
            stickyNote.get(use: self.read)
            stickyNote.patch(use: self.update)
            stickyNote.delete(use: self.delete)
        }
    }

    @Sendable
    func index(req: Request) async throws -> [StickyNoteDTO] {
        try await StickyNote.query(on: req.db).all().map { $0.toDTO() }
    }

    @Sendable
    func create(req: Request) async throws -> StickyNoteDTO {
        guard var body = req.body.data else {
        throw Abort(.badRequest)
    }

        if let bodyString = body.readString(length: body.readableBytes) {
            req.logger.info("Raw body: \(bodyString)")
        } else {
            let bytes = body.getBytes(at: body.readerIndex,
                                    length: body.readableBytes) ?? []

            let hex = bytes.map { String(format: "%02x", $0) }.joined()

            req.logger.info("Raw body (hex): \(hex)")
        }
        
        let dto = try req.content.decode(StickyNoteDTO.self)
        let model = dto.toModel()

        try await model.save(on: req.db)

        guard let saved = try await StickyNote.find(model.id, on: req.db) else {
            throw Abort(.internalServerError)
        }

        return saved.toDTO()
    }

    @Sendable
    func read(req: Request) async throws -> StickyNoteDTO {
        guard let stickyNoteID = req.parameters.get("stickyNoteID", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        guard let note = try await StickyNote.find(stickyNoteID, on: req.db) else {
            throw Abort(.notFound)
        }
        return note.toDTO()
    }

    @Sendable
    func update(req: Request) async throws -> StickyNoteDTO {
        guard let id = req.parameters.get("stickyNoteID", as: UUID.self) else { throw Abort(.badRequest) }
        guard let note = try await StickyNote.find(id, on: req.db) else { throw Abort(.notFound) }

        let dto = try req.content.decode(StickyNoteDTO.self)

        if let title = dto.title {
            note.title = title
        }
        if let validSince = dto.validSince {
            note.validSince = validSince
        }
        if let validUntil = dto.validUntil {
            note.validUntil = validUntil
        }

        try await note.save(on: req.db)

        guard let saved = try await StickyNote.find(note.id, on: req.db) else {
            throw Abort(.internalServerError)
        }
        return saved.toDTO()
    }


    @Sendable
    func delete(req: Request) async throws -> HTTPStatus {
        guard let id = req.parameters.get("stickyNoteID", as: UUID.self),
              let note = try await StickyNote.find(id, on: req.db) else {
            throw Abort(.notFound)
        }

        try await note.delete(on: req.db)
        return .noContent
    }
}
