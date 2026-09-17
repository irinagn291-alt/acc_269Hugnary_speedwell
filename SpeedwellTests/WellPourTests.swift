import XCTest
@testable import Speedwell

final class WellPourTests: XCTestCase {
    private let book = RecipeCatalog.railBook

    func test_primaryVerb_emptyPopulatedInvalid() throws {
        var well = WellDocument.empty
        XCTAssertTrue(well.pourIsEnabled)
        let dry = try well.pourWell(from: book, dayKey: 20260917)
        XCTAssertEqual(dry.kind, .dry)

        _ = try well.addBottle(name: "London dry gin", kind: "gin", id: RailSeedIDs.gin)
        _ = try well.crack(RailSeedIDs.gin, dayKey: 20260917)
        _ = try well.addBottle(name: "Sweet vermouth", kind: "vermouth", id: RailSeedIDs.vermouth)
        _ = try well.crack(RailSeedIDs.vermouth, dayKey: 20260917)

        let poured = try well.pourWell(from: book, dayKey: 20260917) { candidates in
            candidates.first { $0.id == RecipeCatalog.ID.martini }
        }
        XCTAssertEqual(poured.kind, .poured)
        XCTAssertEqual(poured.recipeId, RecipeCatalog.ID.martini)
        XCTAssertEqual(well.bottle(id: RailSeedIDs.gin)?.seat, .seated)
        XCTAssertEqual(well.bottle(id: RailSeedIDs.vermouth)?.seat, .seated)

        let negroni = try XCTUnwrap(book.first { $0.id == RecipeCatalog.ID.negroni })
        do {
            _ = try well.pouring(negroni, dayKey: 20260917)
            XCTFail("campari is missing")
        } catch WellFault.nothingMakeable {
        }

        do {
            _ = try well.crack(UUID(), dayKey: 20260917)
            XCTFail("unknown bottle")
        } catch WellFault.unknownBottle {
        }
    }

    func test_addBottleRejectsEmptyNameAndKind() {
        var well = WellDocument.empty
        XCTAssertThrowsError(try well.addBottle(name: "  ", kind: "gin")) { error in
            XCTAssertEqual(error as? WellFault, .emptyName)
        }
        XCTAssertThrowsError(try well.addBottle(name: "Gin", kind: " ")) { error in
            XCTAssertEqual(error as? WellFault, .emptyKind)
        }
        XCTAssertTrue(well.bottles.isEmpty)
    }
}
