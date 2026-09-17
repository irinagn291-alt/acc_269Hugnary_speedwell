import Foundation

/// Role: One Pour. Leaves bottles Seated. Empty Rail writes Dry. Recipe id is nil on Dry.
enum PourKind: String, Codable, Sendable, Equatable, Hashable {
    case poured
    case dry
}

struct PourMark: Identifiable, Codable, Sendable, Equatable, Hashable {
    let id: UUID
    var recipeId: UUID?
    var kind: PourKind
    let dayKey: Int

    init(id: UUID = UUID(), recipeId: UUID?, kind: PourKind, dayKey: Int) {
        self.id = id
        self.recipeId = recipeId
        self.kind = kind
        self.dayKey = dayKey
    }

    static func poured(id: UUID = UUID(), recipeId: UUID, dayKey: Int) -> PourMark {
        PourMark(id: id, recipeId: recipeId, kind: .poured, dayKey: dayKey)
    }

    static func dry(id: UUID = UUID(), dayKey: Int) -> PourMark {
        PourMark(id: id, recipeId: nil, kind: .dry, dayKey: dayKey)
    }
}
