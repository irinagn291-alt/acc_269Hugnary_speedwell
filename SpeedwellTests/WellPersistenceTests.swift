import XCTest
@testable import Speedwell

@MainActor
final class WellPersistenceTests: XCTestCase {
    func test_roundTrip_writeReload() async throws {
        let folder = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        let suite = "spw.tests.\(UUID().uuidString)"
        let vault = WellVault(source: .suite(suite), folder: folder)
        let store = WellStore(vault: vault, catalog: RecipeCatalog.railBook)
        await store.restore()
        XCTAssertTrue(store.document.bottles.isEmpty)

        let gin = try await store.addBottle(name: "London dry gin", kind: "gin")
        _ = try await store.crack(gin.id)
        let vermouth = try await store.addBottle(name: "Sweet vermouth", kind: "vermouth")
        _ = try await store.crack(vermouth.id)
        _ = try await store.pourWell { $0.first { $0.id == RecipeCatalog.ID.martini } }
        await store.pin(RecipeCatalog.ID.martini)
        await store.flush()

        let reloaded = WellStore(vault: vault, catalog: RecipeCatalog.railBook)
        await reloaded.restore()
        XCTAssertEqual(reloaded.document.bottles.count, 2)
        XCTAssertEqual(reloaded.rail.bottles.count, 2)
        XCTAssertEqual(reloaded.document.pourMarks.first?.kind, .poured)
        XCTAssertEqual(reloaded.document.pourMarks.first?.recipeId, RecipeCatalog.ID.martini)
        XCTAssertEqual(reloaded.document.pinnedRecipeIds, [RecipeCatalog.ID.martini])
        XCTAssertEqual(reloaded.document.schemaVersion, 1)
        XCTAssertEqual(reloaded.bottleSeat(gin.id), .seated)

        await store.resetAllData()
        let cleared = WellStore(vault: vault, catalog: RecipeCatalog.railBook)
        await cleared.restore()
        XCTAssertTrue(cleared.document.bottles.isEmpty)
        XCTAssertFalse(cleared.document.onboardingComplete)

        UserDefaults(suiteName: suite)?.removePersistentDomain(forName: suite)
        try? FileManager.default.removeItem(at: folder)
    }

    func test_corruptPrimaryFallsBackToBackupThenEmpty() async throws {
        let folder = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        let suite = "spw.tests.\(UUID().uuidString)"
        let vault = WellVault(source: .suite(suite), folder: folder)
        let store = WellStore(vault: vault, catalog: RecipeCatalog.railBook)
        await store.installSeededRail()
        await store.flush()

        let box = try XCTUnwrap(UserDefaults(suiteName: suite))
        XCTAssertNotNil(box.data(forKey: WellKey.snapshot))
        if let good = box.data(forKey: WellKey.snapshot) {
            box.set(good, forKey: WellKey.backup)
        }
        box.set(Data("not-a-well".utf8), forKey: WellKey.snapshot)

        let recovered = WellStore(vault: vault, catalog: RecipeCatalog.railBook)
        await recovered.restore()
        XCTAssertTrue(recovered.recoveredFromBackup)
        XCTAssertGreaterThan(recovered.document.bottles.count, 1)
        XCTAssertTrue(recovered.pourIsEnabled)
        XCTAssertFalse(recovered.rail.isEmpty)

        box.set(Data("still-bad".utf8), forKey: WellKey.snapshot)
        box.set(Data("also-bad".utf8), forKey: WellKey.backup)
        try? FileManager.default.removeItem(at: folder.appendingPathComponent("well.json"))
        try? FileManager.default.removeItem(at: folder.appendingPathComponent("well.json.backup"))

        let empty = WellStore(vault: vault, catalog: RecipeCatalog.railBook)
        await empty.restore()
        XCTAssertTrue(empty.startedEmpty)
        XCTAssertTrue(empty.document.bottles.isEmpty)

        UserDefaults(suiteName: suite)?.removePersistentDomain(forName: suite)
        try? FileManager.default.removeItem(at: folder)
    }

    func test_unsupportedSchemaDoesNotCrash() async throws {
        let folder = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        let suite = "spw.tests.\(UUID().uuidString)"
        let box = try XCTUnwrap(UserDefaults(suiteName: suite))
        box.set(Data("{\"schemaVersion\":99}".utf8), forKey: WellKey.snapshot)
        let vault = WellVault(source: .suite(suite), folder: folder)
        let store = WellStore(vault: vault, catalog: RecipeCatalog.railBook)
        await store.restore()
        XCTAssertTrue(store.startedEmpty)
        UserDefaults(suiteName: suite)?.removePersistentDomain(forName: suite)
        try? FileManager.default.removeItem(at: folder)
    }

    func test_recorkPersistsAndDropsMakeable() async throws {
        let store = WellStore(vault: MemoryVault(), catalog: RecipeCatalog.railBook)
        await store.installSeededRail()
        XCTAssertTrue(store.makeable().contains { $0.id == RecipeCatalog.ID.negroni })
        _ = try await store.recork(RailSeedIDs.gin)
        XCTAssertFalse(store.makeable().contains { $0.id == RecipeCatalog.ID.negroni })
        XCTAssertEqual(store.document.bottle(id: RailSeedIDs.gin)?.seat, .backbar)
    }
}

private extension WellStore {
    func bottleSeat(_ id: UUID) -> RailSeat? {
        document.bottle(id: id)?.seat
    }
}
