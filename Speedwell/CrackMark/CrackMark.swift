import Foundation

/// Role: One Crack. Seats a Backbar bottle on the Rail. History stays when Recork lifts the bottle.
struct CrackMark: Identifiable, Codable, Sendable, Equatable, Hashable {
    let id: UUID
    let bottleId: UUID
    let dayKey: Int

    init(id: UUID = UUID(), bottleId: UUID, dayKey: Int) {
        self.id = id
        self.bottleId = bottleId
        self.dayKey = dayKey
    }
}
