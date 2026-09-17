import Foundation

enum WellFault: Error, Sendable, Equatable {
    case unknownBottle
    case alreadySeated
    case notOnRail
    case emptyName
    case emptyKind
    case nothingMakeable
}

enum WellSchemaFault: Error, Sendable, Equatable {
    case unsupported(Int)
}

/// Role: The well is a fold over Bottles. Adding writes Backbar. Crack writes a CrackMark and seats the bottle. Recork returns Backbar. Surprise samples recipes whose bottles are all Seated. Pour writes a PourMark and does not empty the bottle. Empty Rail writes Dry.
/// Display face is SF Pro via Font.system. Tokens: background #F5FAF8, surface #FDFEFE, ink #183931, accent #2CBA96, muted #597870.
struct WellDocument: Codable, Sendable, Equatable {
    var schemaVersion: Int
    var bottles: [Bottle]
    var crackMarks: [CrackMark]
    var pourMarks: [PourMark]
    var pinnedRecipeIds: [UUID]
    var onboardingComplete: Bool

    static let currentSchema = 1

    static var empty: WellDocument {
        WellDocument(
            schemaVersion: currentSchema,
            bottles: [],
            crackMarks: [],
            pourMarks: [],
            pinnedRecipeIds: [],
            onboardingComplete: false
        )
    }

    init(
        schemaVersion: Int = currentSchema,
        bottles: [Bottle],
        crackMarks: [CrackMark],
        pourMarks: [PourMark],
        pinnedRecipeIds: [UUID],
        onboardingComplete: Bool
    ) {
        self.schemaVersion = schemaVersion
        self.bottles = bottles
        self.crackMarks = crackMarks
        self.pourMarks = pourMarks
        self.pinnedRecipeIds = pinnedRecipeIds
        self.onboardingComplete = onboardingComplete
    }

    init(from decoder: Decoder) throws {
        let box = try decoder.container(keyedBy: CodingKeys.self)
        let version = try box.decode(Int.self, forKey: .schemaVersion)
        switch version {
        case 1:
            schemaVersion = 1
            bottles = try box.decodeIfPresent([Bottle].self, forKey: .bottles) ?? []
            crackMarks = try box.decodeIfPresent([CrackMark].self, forKey: .crackMarks) ?? []
            pourMarks = try box.decodeIfPresent([PourMark].self, forKey: .pourMarks) ?? []
            pinnedRecipeIds = try box.decodeIfPresent([UUID].self, forKey: .pinnedRecipeIds) ?? []
            onboardingComplete = try box.decodeIfPresent(Bool.self, forKey: .onboardingComplete) ?? false
        default:
            throw WellSchemaFault.unsupported(version)
        }
    }

    var rail: Rail {
        Rail(bottles: bottles.filter { bottle in
            switch bottle.seat {
            case .seated: true
            case .backbar: false
            }
        })
    }

    var seatedKinds: Set<String> { rail.kinds }

    /// Pour stays tappable on an empty rail. Empty writes Dry.
    var pourIsEnabled: Bool { true }

    func bottle(id: UUID) -> Bottle? {
        bottles.first { $0.id == id }
    }

    func isMakeable(_ recipe: Recipe) -> Bool {
        let have = seatedKinds
        return recipe.bottleKinds.allSatisfy { have.contains($0) }
    }

    func makeable(in recipes: [Recipe]) -> [Recipe] {
        recipes.filter { isMakeable($0) }
    }

    func sights(in recipes: [Recipe]) -> [RecipeSight] {
        recipes.map { recipe in
            let have = seatedKinds
            let missing = recipe.bottleKinds.filter { !have.contains($0) }
            return RecipeSight(recipe: recipe, missingKinds: missing)
        }
    }

    func pinnedRecipes(in recipes: [Recipe]) -> [Recipe] {
        pinnedRecipeIds.compactMap { id in recipes.first { $0.id == id } }
    }

    mutating func addBottle(name: String, kind: String, id: UUID = UUID()) throws -> Bottle {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedKind = kind.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { throw WellFault.emptyName }
        guard !trimmedKind.isEmpty else { throw WellFault.emptyKind }
        let bottle = Bottle(id: id, name: trimmedName, kind: trimmedKind, seat: .backbar)
        bottles.append(bottle)
        return bottle
    }

    mutating func crack(_ id: UUID, dayKey: Int, markId: UUID = UUID()) throws -> Bottle {
        guard let index = bottles.firstIndex(where: { $0.id == id }) else {
            throw WellFault.unknownBottle
        }
        switch bottles[index].seat {
        case .seated:
            throw WellFault.alreadySeated
        case .backbar:
            bottles[index].seat = .seated
            crackMarks.append(CrackMark(id: markId, bottleId: id, dayKey: dayKey))
            return bottles[index]
        }
    }

    mutating func recork(_ id: UUID) throws -> Bottle {
        guard let index = bottles.firstIndex(where: { $0.id == id }) else {
            throw WellFault.unknownBottle
        }
        switch bottles[index].seat {
        case .backbar:
            throw WellFault.notOnRail
        case .seated:
            bottles[index].seat = .backbar
            return bottles[index]
        }
    }

    mutating func pourWell(
        from recipes: [Recipe],
        dayKey: Int,
        markId: UUID = UUID(),
        pick: ([Recipe]) -> Recipe? = { $0.randomElement() }
    ) throws -> PourMark {
        if rail.isEmpty {
            let mark = PourMark.dry(id: markId, dayKey: dayKey)
            pourMarks.append(mark)
            return mark
        }
        let candidates = makeable(in: recipes)
        guard let recipe = pick(candidates) else {
            throw WellFault.nothingMakeable
        }
        return try pouring(recipe, dayKey: dayKey, markId: markId)
    }

    mutating func pouring(_ recipe: Recipe, dayKey: Int, markId: UUID = UUID()) throws -> PourMark {
        guard isMakeable(recipe) else { throw WellFault.nothingMakeable }
        let mark = PourMark.poured(id: markId, recipeId: recipe.id, dayKey: dayKey)
        pourMarks.append(mark)
        return mark
    }

    mutating func pin(_ recipeId: UUID) {
        if !pinnedRecipeIds.contains(recipeId) {
            pinnedRecipeIds.append(recipeId)
        }
    }

    mutating func unpin(_ recipeId: UUID) {
        pinnedRecipeIds.removeAll { $0 == recipeId }
    }

    mutating func completeOnboarding() {
        onboardingComplete = true
    }

    static func seededRail(dayKey: Int = 20260917) -> WellDocument {
        let gin = Bottle(id: RailSeedIDs.gin, name: "London dry gin", kind: "gin", seat: .seated)
        let campari = Bottle(id: RailSeedIDs.campari, name: "Campari", kind: "campari", seat: .seated)
        let vermouth = Bottle(id: RailSeedIDs.vermouth, name: "Sweet vermouth", kind: "vermouth", seat: .seated)
        let whiskey = Bottle(id: RailSeedIDs.whiskey, name: "Rye whiskey", kind: "whiskey", seat: .seated)
        let bitters = Bottle(id: RailSeedIDs.bitters, name: "Aromatic bitters", kind: "bitters", seat: .seated)
        let rum = Bottle(id: RailSeedIDs.rum, name: "White rum", kind: "rum", seat: .backbar)
        let tequila = Bottle(id: RailSeedIDs.tequila, name: "Blanco tequila", kind: "tequila", seat: .backbar)
        let vodka = Bottle(id: RailSeedIDs.vodka, name: "Vodka", kind: "vodka", seat: .backbar)
        let seated = [gin, campari, vermouth, whiskey, bitters]
        let cracks = seated.enumerated().map { offset, bottle in
            CrackMark(
                id: RailSeedIDs.crack(offset + 1),
                bottleId: bottle.id,
                dayKey: dayKey
            )
        }
        return WellDocument(
            schemaVersion: currentSchema,
            bottles: seated + [rum, tequila, vodka],
            crackMarks: cracks,
            pourMarks: [
                PourMark.poured(
                    id: RailSeedIDs.pour1,
                    recipeId: RecipeCatalog.ID.negroni,
                    dayKey: dayKey
                )
            ],
            pinnedRecipeIds: [RecipeCatalog.ID.negroni],
            onboardingComplete: true
        )
    }
}

enum RailSeedIDs {
    /// Fixed UUIDs for the Simulator rail. These literals always parse.
    static let gin = UUID(uuidString: "b1111111-1111-4111-8111-111111111111")!
    static let campari = UUID(uuidString: "b2222222-2222-4222-8222-222222222222")!
    static let vermouth = UUID(uuidString: "b3333333-3333-4333-8333-333333333333")!
    static let whiskey = UUID(uuidString: "b4444444-4444-4444-8444-444444444444")!
    static let bitters = UUID(uuidString: "b5555555-5555-4555-8555-555555555555")!
    static let rum = UUID(uuidString: "b6666666-6666-4666-8666-666666666666")!
    static let tequila = UUID(uuidString: "b7777777-7777-4777-8777-777777777777")!
    static let vodka = UUID(uuidString: "b8888888-8888-4888-8888-888888888888")!
    static let pour1 = UUID(uuidString: "c1111111-1111-4111-8111-111111111111")!

    static func crack(_ index: Int) -> UUID {
        let hex = String(format: "c2222222-2222-4222-8222-22222222222%d", index)
        return UUID(uuidString: hex) ?? UUID()
    }
}
