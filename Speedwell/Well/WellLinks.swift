import Foundation

/// Role: Well-link chrome. Surprise holds the well. Bar, Discover, Favorites, and Settings arrive as sheets. No Game tab.
enum WellSheet: String, Sendable, Equatable, CaseIterable {
    case bar
    case discover
    case favorites
    case settings
}

enum WellJob: Equatable, Sendable {
    case surprise
    case pour
    case sheet(WellSheet)
}

/// Launch keys for live shots. today / log / goals open three different screens.
/// Extra cover slugs from this app's screens open those screens, not home.
enum WellPane: String, Equatable, Sendable {
    case today
    case log
    case goals
    case surprise
    case bar
    case discover
    case favorites
    case settings

    var job: WellJob {
        switch self {
        case .today, .surprise: .surprise
        case .log, .bar: .sheet(.bar)
        case .goals, .settings: .sheet(.settings)
        case .discover: .sheet(.discover)
        case .favorites: .sheet(.favorites)
        }
    }

    static func parse(_ token: String) -> WellPane? {
        let key = token.lowercased()
        if let pane = WellPane(rawValue: key) {
            return pane
        }
        switch key {
        case "home":
            return .today
        default:
            return nil
        }
    }
}

/// Role: Parses `-ReviewScreen today|log|goals` once after onboarding, and speedwell:// URLs. Never hosts a View.
enum WellLinks {
    static func isReviewLaunch(arguments: [String] = ProcessInfo.processInfo.arguments) -> Bool {
        arguments.contains("-ReviewScreen")
    }

    static func parse(arguments: [String] = ProcessInfo.processInfo.arguments) -> WellPane? {
        guard let index = arguments.firstIndex(of: "-ReviewScreen") else { return nil }
        let next = arguments.index(after: index)
        guard arguments.indices.contains(next) else { return nil }
        return WellPane.parse(arguments[next])
    }

    static func consume(
        arguments: [String] = ProcessInfo.processInfo.arguments,
        onboardingComplete: Bool,
        consumed: inout Bool
    ) -> WellPane? {
        guard onboardingComplete, !consumed else { return nil }
        consumed = true
        return parse(arguments: arguments)
    }

    static func parseURL(_ url: URL) -> WellJob? {
        guard url.scheme == "speedwell" else { return nil }
        let host = url.host?.lowercased() ?? ""
        let path = url.path.lowercased().trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        let token = host.isEmpty ? path : host
        switch token {
        case "surprise":
            return .surprise
        case "pour":
            return .pour
        case "bar":
            return .sheet(.bar)
        case "discover":
            return .sheet(.discover)
        case "favorites":
            return .sheet(.favorites)
        case "settings":
            return .sheet(.settings)
        default:
            return nil
        }
    }
}
