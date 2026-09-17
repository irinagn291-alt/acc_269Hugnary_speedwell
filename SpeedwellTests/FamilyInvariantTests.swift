import XCTest
@testable import Speedwell

/// Family invariant: Surprise filters recipes by owned bottles. random.php without stock is a failed verb.
/// Desk cellar_window: tempFactor=(cellarC-13)*0.5 yr; young/approaching/ready/holding/pastPeak from vintage+peak window.
final class FamilyInvariantTests: XCTestCase {
    private let book = RecipeCatalog.railBook

    func test_surpriseFiltersRecipesByOwnedBottles_randomPhpWithoutStockIsAFailedVerb() throws {
        var well = WellDocument.empty
        XCTAssertTrue(well.rail.isEmpty)
        XCTAssertTrue(well.makeable(in: book).isEmpty, "random.php without stock is a failed verb")

        let rum = try well.addBottle(name: "White rum", kind: "rum", id: RailSeedIDs.rum)
        XCTAssertEqual(rum.seat, .backbar)
        XCTAssertTrue(well.makeable(in: book).isEmpty, "Backbar stock is owned but Surprise ignores sealed bottles")

        _ = try well.crack(rum.id, dayKey: 20260917)
        let daiquiri = try XCTUnwrap(book.first { $0.id == RecipeCatalog.ID.daiquiri })
        XCTAssertFalse(well.isMakeable(daiquiri), "lime is not seated")

        _ = try well.addBottle(name: "Lime cordial", kind: "lime")
        let lime = try XCTUnwrap(well.bottles.first { $0.kind == "lime" })
        _ = try well.crack(lime.id, dayKey: 20260917)

        let makeable = well.makeable(in: book)
        XCTAssertTrue(makeable.contains(where: { $0.id == RecipeCatalog.ID.daiquiri }))
        XCTAssertFalse(makeable.contains(where: { $0.id == RecipeCatalog.ID.negroni }))
        XCTAssertLessThan(makeable.count, book.count, "Surprise never samples the full catalog")

        let mark = try well.pourWell(from: book, dayKey: 20260917) { candidates in
            candidates.first { $0.id == RecipeCatalog.ID.daiquiri }
        }
        XCTAssertEqual(mark.kind, .poured)
        XCTAssertEqual(mark.recipeId, RecipeCatalog.ID.daiquiri)
        XCTAssertEqual(well.bottle(id: rum.id)?.seat, .seated, "Pour does not empty the bottle")
    }

    func test_emptyRailWritesDry_notACatalogDice() throws {
        var well = WellDocument.empty
        let mark = try well.pourWell(from: book, dayKey: 20260917)
        XCTAssertEqual(mark.kind, .dry)
        XCTAssertNil(mark.recipeId)
        XCTAssertEqual(well.pourMarks.count, 1)
        XCTAssertTrue(well.makeable(in: book).isEmpty)
    }

    func test_seededRailLetsPourSampleASeatedRecipe() {
        let well = WellDocument.seededRail()
        XCTAssertTrue(well.onboardingComplete)
        XCTAssertTrue(well.pourIsEnabled)
        XCTAssertGreaterThanOrEqual(well.rail.bottles.count, 4)
        XCTAssertFalse(well.rail.isEmpty)
        let makeable = well.makeable(in: book)
        XCTAssertTrue(makeable.contains(where: { $0.id == RecipeCatalog.ID.negroni }))
        XCTAssertTrue(makeable.contains(where: { $0.id == RecipeCatalog.ID.manhattan }))
        XCTAssertFalse(makeable.contains(where: { $0.id == RecipeCatalog.ID.daiquiri }), "rum stays Backbar")
        XCTAssertEqual(well.pourMarks.first?.kind, .poured)
        XCTAssertFalse(well.pinnedRecipeIds.isEmpty)
        XCTAssertGreaterThanOrEqual(well.crackMarks.count, 5)
    }
}
