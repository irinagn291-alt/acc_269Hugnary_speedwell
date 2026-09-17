import Foundation
import Observation
import SwiftUI

extension WellSheet: Identifiable {
    var id: String { rawValue }
}

/// Role: Well-link chrome director. Surprise never leaves. Views call crack, recork, and pourWell here and never keep a second stock enum.
@Observable
@MainActor
final class WellBooth {
    static let shared = WellBooth()

    private(set) var store: WellStore?
    private(set) var document: WellDocument = .empty
    private(set) var isReady = false
    private(set) var recoveredFromBackup = false
    var showOnboarding = false
    var presentedSheet: WellSheet?
    var crackPresented = false
    var verbBusy = false
    var pourLoading = false
    var commitPulse = 0
    var commitFlash = false
    var surpriseFault: String?
    var barFault: String?
    var discoverFault: String?
    var favoritesFault: String?
    var settingsFault: String?
    var bootFault: String?
    var addDraftName = ""
    var addDraftKind = "gin"

    @ObservationIgnored private var reviewConsumed = false
    @ObservationIgnored private var booted = false
    @ObservationIgnored private var pendingJob: WellJob?
    @ObservationIgnored private var spinnerTask: Task<Void, Never>?

    var recipes: [Recipe] { store?.recipes ?? RecipeCatalog.railBook }
    var pourIsEnabled: Bool { document.pourIsEnabled }
    var railEmpty: Bool { document.rail.isEmpty }
    var barEmpty: Bool { document.bottles.isEmpty }
    var seated: [Bottle] {
        document.bottles.filter { bottle in
            switch bottle.seat {
            case .seated: true
            case .backbar: false
            }
        }
    }
    var backbar: [Bottle] {
        document.bottles.filter { bottle in
            switch bottle.seat {
            case .backbar: true
            case .seated: false
            }
        }
    }
    var makeable: [Recipe] { document.makeable(in: recipes) }
    var sights: [RecipeSight] { document.sights(in: recipes) }
    var favorites: [Recipe] { document.pinnedRecipes(in: recipes) }
    var pouredRecipe: Recipe? {
        guard
            let mark = document.pourMarks.last,
            mark.kind == .poured,
            let id = mark.recipeId
        else { return nil }
        return recipes.first { $0.id == id }
    }
    var lastPourWasDry: Bool {
        document.pourMarks.last?.kind == .dry
    }
    var kindChoices: [String] {
        var set = Set(recipes.flatMap(\.bottleKinds))
        for bottle in document.bottles {
            set.insert(bottle.kind)
        }
        return set.sorted()
    }

    init() {}

    init(testing store: WellStore) {
        self.store = store
        self.document = store.document
        self.isReady = true
        self.booted = true
        self.showOnboarding = !store.document.onboardingComplete
        self.recoveredFromBackup = store.recoveredFromBackup
    }

    func boot() async {
        if booted, store != nil {
            isReady = true
            return
        }
        bootFault = nil
        do {
            let folder = try WellPaths.supportFolder()
            let vault = WellVault(source: .standard, folder: folder)
            let well = WellStore(vault: vault)
            await well.restore()
            await well.plantSimulatorSeedIfNeeded()
            store = well
            document = well.document
            recoveredFromBackup = well.recoveredFromBackup
            booted = true
            isReady = true
            showOnboarding = !well.document.onboardingComplete
            if well.recoveredFromBackup {
                surpriseFault = "Well recovered from a backup."
                settingsFault = "Well recovered from a backup."
            }
        } catch {
            bootFault = "The well folder could not be opened."
            isReady = false
        }
    }

    func retryBoot() async {
        booted = false
        await boot()
    }

    func handle(phase: ScenePhase) async {
        guard let store else { return }
        switch phase {
        case .inactive, .background:
            await store.flush()
        case .active:
            sync()
        @unknown default:
            await store.flush()
        }
    }

    func open(url: URL) {
        guard let job = WellLinks.parseURL(url) else { return }
        open(job)
    }

    func open(_ job: WellJob) {
        guard isReady, !showOnboarding else {
            pendingJob = job
            return
        }
        apply(job)
    }

    func present(_ sheet: WellSheet) {
        presentedSheet = sheet
        crackPresented = false
    }

    func presentCrack() {
        presentedSheet = nil
        crackPresented = true
    }

    func apply(_ job: WellJob) {
        switch job {
        case .surprise:
            presentedSheet = nil
            crackPresented = false
        case .pour:
            presentedSheet = nil
            crackPresented = false
            Task { await pourWell() }
        case .sheet(let sheet):
            crackPresented = false
            presentedSheet = sheet
        }
    }

    func ingestReview(arguments: [String] = ProcessInfo.processInfo.arguments) {
        guard isReady, !showOnboarding else { return }
        if let pane = WellLinks.consume(
            arguments: arguments,
            onboardingComplete: true,
            consumed: &reviewConsumed
        ) {
            pendingJob = nil
            apply(pane.job)
        }
    }

    func noteChromeVisible() {
        ingestReview(arguments: ProcessInfo.processInfo.arguments)
        applyPendingJob()
    }

    func finishOnboarding() async {
        guard let store else { return }
        await store.setOnboardingComplete(true)
        await store.flush()
        sync()
        showOnboarding = false
    }

    func replayOnboarding() {
        presentedSheet = nil
        crackPresented = false
        showOnboarding = true
    }

    @discardableResult
    func pourWell() async -> PourMark? {
        guard let store, !verbBusy else { return nil }
        verbBusy = true
        surpriseFault = nil
        armSpinner()
        defer { clearSpinner() }
        do {
            let mark = try await store.pourWell()
            sync()
            WellPulse.commit()
            pulseCommit(spring: true)
            return mark
        } catch {
            surpriseFault = WellInk.fault(error)
            return nil
        }
    }

    func crack(_ id: UUID) async {
        guard let store, !verbBusy else { return }
        verbBusy = true
        barFault = nil
        surpriseFault = nil
        defer { verbBusy = false }
        do {
            _ = try await store.crack(id)
            sync()
            WellPulse.commit()
            pulseCommit(spring: true)
        } catch {
            let line = WellInk.fault(error)
            barFault = line
            surpriseFault = line
        }
    }

    func recork(_ id: UUID) async {
        guard let store, !verbBusy else { return }
        verbBusy = true
        barFault = nil
        surpriseFault = nil
        defer { verbBusy = false }
        do {
            _ = try await store.recork(id)
            sync()
            WellPulse.commit()
        } catch {
            let line = WellInk.fault(error)
            barFault = line
            surpriseFault = line
        }
    }

    func addBottle() async {
        guard let store else { return }
        barFault = nil
        do {
            _ = try await store.addBottle(name: addDraftName, kind: addDraftKind)
            sync()
            addDraftName = ""
        } catch {
            barFault = WellInk.fault(error)
        }
    }

    func pin(_ recipeId: UUID) async {
        guard let store else { return }
        favoritesFault = nil
        await store.pin(recipeId)
        sync()
    }

    func unpin(_ recipeId: UUID) async {
        guard let store else { return }
        favoritesFault = nil
        await store.unpin(recipeId)
        sync()
    }

    func isPinned(_ recipeId: UUID) -> Bool {
        document.pinnedRecipeIds.contains(recipeId)
    }

    func togglePin(_ recipeId: UUID) async {
        if isPinned(recipeId) {
            await unpin(recipeId)
        } else {
            await pin(recipeId)
        }
    }

    func resetAllData() async {
        guard let store else { return }
        settingsFault = nil
        await store.resetAllData()
        sync()
        presentedSheet = nil
        crackPresented = false
        showOnboarding = true
        addDraftName = ""
        addDraftKind = kindChoices.first ?? "gin"
        surpriseFault = nil
        barFault = nil
        discoverFault = nil
        favoritesFault = nil
    }

    func retrySurprise() {
        surpriseFault = nil
        sync()
    }

    func retryBar() {
        barFault = nil
        sync()
    }

    func retryDiscover() {
        discoverFault = nil
        sync()
    }

    func retryFavorites() {
        favoritesFault = nil
        sync()
    }

    func retrySettings() {
        settingsFault = nil
        sync()
    }

    func backbarBottle(kind: String) -> Bottle? {
        backbar.first { $0.kind == kind }
    }

    private func applyPendingJob() {
        guard isReady, !showOnboarding, let job = pendingJob else { return }
        pendingJob = nil
        apply(job)
    }

    private func sync() {
        guard let store else { return }
        document = store.document
        recoveredFromBackup = store.recoveredFromBackup
    }

    private func pulseCommit(spring: Bool) {
        commitFlash = true
        if spring {
            commitPulse += 1
        }
        Task {
            do {
                try await Task.sleep(for: .milliseconds(700))
            } catch {
                commitFlash = false
                return
            }
            commitFlash = false
        }
    }

    private func armSpinner() {
        pourLoading = false
        spinnerTask?.cancel()
        spinnerTask = Task { @MainActor [weak self] in
            do {
                try await Task.sleep(for: WellMeasure.spinnerGate)
            } catch {
                return
            }
            guard let self, !Task.isCancelled else { return }
            if self.verbBusy {
                self.pourLoading = true
            }
        }
    }

    private func clearSpinner() {
        spinnerTask?.cancel()
        spinnerTask = nil
        pourLoading = false
        verbBusy = false
    }
}
