import Foundation
import Observation

/// Role: Observable fold over Bottles. Views call crack, recork, and pourWell and never keep a second stock enum.
/// Display face is SF Pro via Font.system. Tokens: background #F5FAF8, surface #FDFEFE, ink #183931, accent #2CBA96, muted #597870.
@Observable
@MainActor
final class WellStore {
    private let vault: any WellProjecting
    private let catalog: [Recipe]
    private let calendar: Calendar
    private var persistTask: Task<Void, Never>?

    private(set) var document: WellDocument
    private(set) var recoveredFromBackup: Bool
    private(set) var startedEmpty: Bool

    init(
        vault: any WellProjecting,
        catalog: [Recipe] = RecipeCatalog.bundled,
        calendar: Calendar = .current
    ) {
        self.vault = vault
        self.catalog = catalog
        self.calendar = calendar
        self.document = .empty
        self.recoveredFromBackup = false
        self.startedEmpty = true
    }

    var recipes: [Recipe] { catalog }
    var pourIsEnabled: Bool { document.pourIsEnabled }
    var rail: Rail { document.rail }

    func makeable() -> [Recipe] {
        document.makeable(in: catalog)
    }

    func sights() -> [RecipeSight] {
        document.sights(in: catalog)
    }

    func restore() async {
        let load = await vault.load()
        document = load.document
        recoveredFromBackup = load.recoveredFromBackup
        startedEmpty = load.startedEmpty
    }

    func flush() async {
        persistTask?.cancel()
        persistTask = nil
        await vault.save(document)
    }

    func resetAllData() async {
        persistTask?.cancel()
        persistTask = nil
        document = .empty
        await vault.wipe()
        await vault.save(document)
    }

    func plantSimulatorSeedIfNeeded() async {
        #if targetEnvironment(simulator)
        let planted = await vault.demoPlanted()
        if planted, document.onboardingComplete, !document.rail.isEmpty {
            return
        }
        document = .seededRail(dayKey: WellDay.key(calendar: calendar))
        await vault.markDemoPlanted()
        await flush()
        #endif
    }

    func installSeededRail(dayKey: Int = 20260917) async {
        document = .seededRail(dayKey: dayKey)
        await flush()
    }

    @discardableResult
    func addBottle(name: String, kind: String) async throws -> Bottle {
        let bottle = try document.addBottle(name: name, kind: kind)
        await flush()
        return bottle
    }

    @discardableResult
    func crack(_ id: UUID) async throws -> Bottle {
        let bottle = try document.crack(id, dayKey: WellDay.key(calendar: calendar))
        await flush()
        return bottle
    }

    @discardableResult
    func recork(_ id: UUID) async throws -> Bottle {
        let bottle = try document.recork(id)
        await flush()
        return bottle
    }

    @discardableResult
    func pourWell(pick: ([Recipe]) -> Recipe? = { $0.randomElement() }) async throws -> PourMark {
        let mark = try document.pourWell(
            from: catalog,
            dayKey: WellDay.key(calendar: calendar),
            pick: pick
        )
        await flush()
        return mark
    }

    func pin(_ recipeId: UUID) async {
        document.pin(recipeId)
        await flush()
    }

    func unpin(_ recipeId: UUID) async {
        document.unpin(recipeId)
        await flush()
    }

    func setOnboardingComplete(_ flag: Bool) async {
        document.onboardingComplete = flag
        schedulePersist()
    }

    private func schedulePersist() {
        persistTask?.cancel()
        persistTask = Task { @MainActor [weak self] in
            try? await Task.sleep(for: .milliseconds(300))
            guard !Task.isCancelled else { return }
            await self?.flush()
        }
    }
}
