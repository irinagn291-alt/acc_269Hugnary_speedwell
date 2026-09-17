import Foundation

/// Role: Bundled local recipe. Required bottle kinds must all sit Seated before Surprise will sample it.
struct Recipe: Identifiable, Codable, Sendable, Equatable, Hashable {
    let id: UUID
    var name: String
    var bottleKinds: [String]
    var method: String

    init(id: UUID, name: String, bottleKinds: [String], method: String) {
        self.id = id
        self.name = name
        self.bottleKinds = bottleKinds
        self.method = method
    }
}

/// Role: Makeable versus missing seated bottles. Derived at display. Never stored on the well.
struct RecipeSight: Sendable, Equatable, Identifiable {
    var recipe: Recipe
    var missingKinds: [String]

    var id: UUID { recipe.id }
    var isMakeable: Bool { missingKinds.isEmpty }
}
