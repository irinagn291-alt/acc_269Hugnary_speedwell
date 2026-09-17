import AppIntents

/// App Intents open Surprise, Bar, Discover, Favorites, or Settings, or fire Pour in place.
struct OpenSurpriseIntent: AppIntent {
    static var title: LocalizedStringResource { "Open Surprise" }
    static var description: IntentDescription { "Open tonight's well." }
    static var openAppWhenRun: Bool { true }

    func perform() async throws -> some IntentResult {
        await WellBooth.shared.open(.surprise)
        return .result()
    }
}

struct PourWellIntent: AppIntent {
    static var title: LocalizedStringResource { "Pour" }
    static var description: IntentDescription { "Pour one cocktail from seated bottles." }
    static var openAppWhenRun: Bool { true }

    func perform() async throws -> some IntentResult {
        await WellBooth.shared.open(.pour)
        return .result()
    }
}

struct OpenBarIntent: AppIntent {
    static var title: LocalizedStringResource { "Open Bar" }
    static var description: IntentDescription { "Open owned bottles. Crack and Recork." }
    static var openAppWhenRun: Bool { true }

    func perform() async throws -> some IntentResult {
        await WellBooth.shared.open(.sheet(.bar))
        return .result()
    }
}

struct OpenDiscoverIntent: AppIntent {
    static var title: LocalizedStringResource { "Open Discover" }
    static var description: IntentDescription { "Open makeable recipes versus missing seated bottles." }
    static var openAppWhenRun: Bool { true }

    func perform() async throws -> some IntentResult {
        await WellBooth.shared.open(.sheet(.discover))
        return .result()
    }
}

struct OpenFavoritesIntent: AppIntent {
    static var title: LocalizedStringResource { "Open Favorites" }
    static var description: IntentDescription { "Open pinned recipes." }
    static var openAppWhenRun: Bool { true }

    func perform() async throws -> some IntentResult {
        await WellBooth.shared.open(.sheet(.favorites))
        return .result()
    }
}

struct OpenSettingsIntent: AppIntent {
    static var title: LocalizedStringResource { "Open Settings" }
    static var description: IntentDescription { "Open reset, catalog credit, and contact." }
    static var openAppWhenRun: Bool { true }

    func perform() async throws -> some IntentResult {
        await WellBooth.shared.open(.sheet(.settings))
        return .result()
    }
}

struct SpeedwellShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: PourWellIntent(),
            phrases: [
                "Pour in \(.applicationName)",
                "Pour a cocktail in \(.applicationName)",
            ],
            shortTitle: "Pour",
            systemImageName: "drop"
        )
        AppShortcut(
            intent: OpenSurpriseIntent(),
            phrases: [
                "Open Surprise in \(.applicationName)",
            ],
            shortTitle: "Surprise",
            systemImageName: "drop.fill"
        )
        AppShortcut(
            intent: OpenBarIntent(),
            phrases: [
                "Open Bar in \(.applicationName)",
            ],
            shortTitle: "Bar",
            systemImageName: "cabinet"
        )
        AppShortcut(
            intent: OpenDiscoverIntent(),
            phrases: [
                "Open Discover in \(.applicationName)",
            ],
            shortTitle: "Discover",
            systemImageName: "list.bullet"
        )
        AppShortcut(
            intent: OpenFavoritesIntent(),
            phrases: [
                "Open Favorites in \(.applicationName)",
            ],
            shortTitle: "Favorites",
            systemImageName: "bookmark"
        )
        AppShortcut(
            intent: OpenSettingsIntent(),
            phrases: [
                "Open Settings in \(.applicationName)",
            ],
            shortTitle: "Settings",
            systemImageName: "gearshape"
        )
    }
}
