import XCTest
@testable import Speedwell

@MainActor
final class WellBoothTests: XCTestCase {
    func test_reviewKeysOpenThreeDifferentSurfaces() async {
        let today = await seededSession()
        today.ingestReview(arguments: ["-ReviewScreen", "today"])
        XCTAssertNil(today.presentedSheet)
        XCTAssertFalse(today.crackPresented)

        let log = await seededSession()
        log.ingestReview(arguments: ["-ReviewScreen", "log"])
        XCTAssertEqual(log.presentedSheet, .bar)

        let goals = await seededSession()
        goals.ingestReview(arguments: ["-ReviewScreen", "goals"])
        XCTAssertEqual(goals.presentedSheet, .settings)

        XCTAssertNotEqual(today.presentedSheet, log.presentedSheet)
        XCTAssertNotEqual(log.presentedSheet, goals.presentedSheet)
        XCTAssertNotEqual(today.presentedSheet, goals.presentedSheet)
    }

    func test_extraReviewSlugsOpenNamedSheets() async {
        let discover = await seededSession()
        discover.ingestReview(arguments: ["-ReviewScreen", "discover"])
        XCTAssertEqual(discover.presentedSheet, .discover)

        let favorites = await seededSession()
        favorites.ingestReview(arguments: ["-ReviewScreen", "favorites"])
        XCTAssertEqual(favorites.presentedSheet, .favorites)

        let bar = await seededSession()
        bar.ingestReview(arguments: ["-ReviewScreen", "bar"])
        XCTAssertEqual(bar.presentedSheet, .bar)

        let settings = await seededSession()
        settings.ingestReview(arguments: ["-ReviewScreen", "settings"])
        XCTAssertEqual(settings.presentedSheet, .settings)

        let surprise = await seededSession()
        surprise.ingestReview(arguments: ["-ReviewScreen", "surprise"])
        XCTAssertNil(surprise.presentedSheet)
    }

    func test_ingestReviewWaitsUntilOnboardingIsDone() async {
        let store = WellStore(vault: MemoryVault(), catalog: RecipeCatalog.railBook)
        await store.restore()
        let session = WellBooth(testing: store)
        XCTAssertTrue(session.showOnboarding)
        session.ingestReview(arguments: ["-ReviewScreen", "log"])
        XCTAssertNil(session.presentedSheet)
        session.showOnboarding = false
        session.ingestReview(arguments: ["-ReviewScreen", "log"])
        XCTAssertEqual(session.presentedSheet, .bar)
    }

    func test_ingestReviewReadsProcessInfoOnce() async {
        let session = await seededSession()
        session.ingestReview(arguments: ProcessInfo.processInfo.arguments)
        session.ingestReview(arguments: ["-ReviewScreen", "log"])
        XCTAssertNil(session.presentedSheet)
    }

    func test_pourOnEmptyRailWritesDry() async throws {
        let store = WellStore(vault: MemoryVault(), catalog: RecipeCatalog.railBook)
        await store.restore()
        let session = WellBooth(testing: store)
        XCTAssertTrue(session.barEmpty)
        let dry = await session.pourWell()
        let mark = try XCTUnwrap(dry)
        XCTAssertEqual(mark.kind, .dry)
        XCTAssertTrue(session.document.bottles.isEmpty)
        XCTAssertEqual(session.document.pourMarks.count, 1)
    }

    func test_crackThenPourThroughSessionLeavesBottlesSeated() async throws {
        let store = WellStore(vault: MemoryVault(), catalog: RecipeCatalog.railBook)
        await store.restore()
        let session = WellBooth(testing: store)
        session.addDraftName = "London dry gin"
        session.addDraftKind = "gin"
        await session.addBottle()
        session.addDraftName = "Sweet vermouth"
        session.addDraftKind = "vermouth"
        await session.addBottle()
        XCTAssertTrue(session.makeable.isEmpty)

        let gin = try XCTUnwrap(session.document.bottles.first { $0.kind == "gin" })
        let vermouth = try XCTUnwrap(session.document.bottles.first { $0.kind == "vermouth" })
        await session.crack(gin.id)
        await session.crack(vermouth.id)
        XCTAssertTrue(session.makeable.contains { $0.id == RecipeCatalog.ID.martini })

        let poured = await session.pourWell()
        let mark = try XCTUnwrap(poured)
        XCTAssertEqual(mark.kind, .poured)
        XCTAssertEqual(session.document.bottle(id: gin.id)?.seat, .seated)
        XCTAssertEqual(session.document.bottle(id: vermouth.id)?.seat, .seated)

        await session.recork(gin.id)
        XCTAssertFalse(session.makeable.contains { $0.id == RecipeCatalog.ID.martini })
        XCTAssertEqual(session.document.bottle(id: gin.id)?.seat, .backbar)
    }

    func test_speedwellURLOpensSheets() async throws {
        let session = await seededSession()
        session.open(url: try XCTUnwrap(URL(string: "speedwell://bar")))
        XCTAssertEqual(session.presentedSheet, .bar)
        session.open(url: try XCTUnwrap(URL(string: "speedwell://settings")))
        XCTAssertEqual(session.presentedSheet, .settings)
        session.open(url: try XCTUnwrap(URL(string: "speedwell://surprise")))
        XCTAssertNil(session.presentedSheet)
        session.open(.sheet(.discover))
        XCTAssertEqual(session.presentedSheet, .discover)
        session.open(.sheet(.favorites))
        XCTAssertEqual(session.presentedSheet, .favorites)
    }

    private func seededSession() async -> WellBooth {
        let store = WellStore(
            vault: MemoryVault(document: .seededRail()),
            catalog: RecipeCatalog.railBook
        )
        await store.restore()
        return WellBooth(testing: store)
    }
}
