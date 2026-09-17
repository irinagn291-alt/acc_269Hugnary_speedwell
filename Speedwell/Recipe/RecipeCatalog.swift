import Foundation

/// Role: Read-only bundled recipe book. Not copied into WellDocument. No remote catalog.
enum RecipeCatalog {
    struct File: Codable, Sendable {
        var schemaVersion: Int
        var recipes: [Recipe]
    }

    /// Programmer constants. These 32-hex strings always parse.
    enum ID {
        static let negroni = UUID(uuidString: "a1111111-1111-4111-8111-111111111111")!
        static let martini = UUID(uuidString: "a2222222-2222-4222-8222-222222222222")!
        static let manhattan = UUID(uuidString: "a3333333-3333-4333-8333-333333333333")!
        static let oldFashioned = UUID(uuidString: "a4444444-4444-4444-8444-444444444444")!
        static let boulevardier = UUID(uuidString: "a5555555-5555-4555-8555-555555555555")!
        static let daiquiri = UUID(uuidString: "a6666666-6666-4666-8666-666666666666")!
        static let margarita = UUID(uuidString: "a7777777-7777-4777-8777-777777777777")!
        static let paloma = UUID(uuidString: "a8888888-8888-4888-8888-888888888888")!
        static let french75 = UUID(uuidString: "a9999999-9999-4999-8999-999999999999")!
        static let whiskeySour = UUID(uuidString: "aaaaaaa1-aaa1-4aa1-8aa1-aaaaaaaaaaa1")!
        static let espressoMartini = UUID(uuidString: "aaaaaaa2-aaa2-4aa2-8aa2-aaaaaaaaaaa2")!
        static let ginRickey = UUID(uuidString: "aaaaaaa3-aaa3-4aa3-8aa3-aaaaaaaaaaa3")!
    }

    static let railBook: [Recipe] = [
        Recipe(
            id: ID.negroni,
            name: "Negroni",
            bottleKinds: ["gin", "campari", "vermouth"],
            method: "Stir equal parts over ice. Orange peel."
        ),
        Recipe(
            id: ID.martini,
            name: "Martini",
            bottleKinds: ["gin", "vermouth"],
            method: "Stir gin and vermouth. Lemon twist."
        ),
        Recipe(
            id: ID.manhattan,
            name: "Manhattan",
            bottleKinds: ["whiskey", "vermouth", "bitters"],
            method: "Stir rye, vermouth, and bitters. Cherry."
        ),
        Recipe(
            id: ID.oldFashioned,
            name: "Old Fashioned",
            bottleKinds: ["whiskey", "bitters"],
            method: "Build whiskey and bitters over ice. Orange peel."
        ),
        Recipe(
            id: ID.boulevardier,
            name: "Boulevardier",
            bottleKinds: ["whiskey", "campari", "vermouth"],
            method: "Stir whiskey, Campari, and vermouth. Orange peel."
        ),
        Recipe(
            id: ID.daiquiri,
            name: "Daiquiri",
            bottleKinds: ["rum", "lime"],
            method: "Shake rum and lime. Coupe."
        ),
        Recipe(
            id: ID.margarita,
            name: "Margarita",
            bottleKinds: ["tequila", "triple_sec", "lime"],
            method: "Shake tequila, triple sec, and lime. Salt optional."
        ),
        Recipe(
            id: ID.paloma,
            name: "Paloma",
            bottleKinds: ["tequila", "lime"],
            method: "Build tequila and lime over ice."
        ),
        Recipe(
            id: ID.french75,
            name: "French 75",
            bottleKinds: ["gin", "sparkling", "lemon"],
            method: "Shake gin and lemon. Top sparkling."
        ),
        Recipe(
            id: ID.whiskeySour,
            name: "Whiskey Sour",
            bottleKinds: ["whiskey", "lemon"],
            method: "Shake whiskey and lemon. Coupe."
        ),
        Recipe(
            id: ID.espressoMartini,
            name: "Espresso Martini",
            bottleKinds: ["vodka", "coffee_liqueur"],
            method: "Shake vodka and coffee liqueur. Coupe."
        ),
        Recipe(
            id: ID.ginRickey,
            name: "Gin Rickey",
            bottleKinds: ["gin", "lime"],
            method: "Build gin and lime over ice."
        ),
    ]

    static let bundled: [Recipe] = load()

    static func load(from bundle: Bundle = .main) -> [Recipe] {
        guard
            let url = bundle.url(forResource: "recipes", withExtension: "json"),
            let data = try? Data(contentsOf: url)
        else {
            return railBook
        }
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .useDefaultKeys
        guard let file = try? decoder.decode(File.self, from: data), file.schemaVersion == 1 else {
            return railBook
        }
        return file.recipes.isEmpty ? railBook : file.recipes
    }

    static func recipe(id: UUID, in recipes: [Recipe] = bundled) -> Recipe? {
        recipes.first { $0.id == id }
    }
}
