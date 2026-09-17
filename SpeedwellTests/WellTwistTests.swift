import XCTest
@testable import Speedwell

final class WellTwistTests: XCTestCase {
    private let book = RecipeCatalog.railBook

    func test_crackThenPour_recorkDropsRecipes_pourDoesNotEmpty_dryOnEmptyRail() throws {
        var well = WellDocument.empty
        _ = try well.addBottle(name: "London dry gin", kind: "gin", id: RailSeedIDs.gin)
        _ = try well.addBottle(name: "Campari", kind: "campari", id: RailSeedIDs.campari)
        _ = try well.addBottle(name: "Sweet vermouth", kind: "vermouth", id: RailSeedIDs.vermouth)

        XCTAssertTrue(well.makeable(in: book).isEmpty)

        _ = try well.crack(RailSeedIDs.gin, dayKey: 20260917)
        _ = try well.crack(RailSeedIDs.campari, dayKey: 20260917)
        XCTAssertTrue(well.makeable(in: book).isEmpty, "Negroni still misses vermouth")

        _ = try well.crack(RailSeedIDs.vermouth, dayKey: 20260917)
        XCTAssertEqual(well.crackMarks.count, 3)
        XCTAssertTrue(well.isMakeable(try XCTUnwrap(book.first { $0.id == RecipeCatalog.ID.negroni })))

        let poured = try well.pourWell(from: book, dayKey: 20260917) { $0.first { $0.id == RecipeCatalog.ID.negroni } }
        XCTAssertEqual(poured.kind, .poured)
        XCTAssertEqual(well.bottle(id: RailSeedIDs.gin)?.seat, .seated)
        XCTAssertEqual(well.bottle(id: RailSeedIDs.campari)?.seat, .seated)
        XCTAssertEqual(well.bottle(id: RailSeedIDs.vermouth)?.seat, .seated)

        _ = try well.recork(RailSeedIDs.campari)
        XCTAssertEqual(well.bottle(id: RailSeedIDs.campari)?.seat, .backbar)
        XCTAssertFalse(well.isMakeable(try XCTUnwrap(book.first { $0.id == RecipeCatalog.ID.negroni })))
        XCTAssertTrue(well.isMakeable(try XCTUnwrap(book.first { $0.id == RecipeCatalog.ID.martini })))
        XCTAssertEqual(well.crackMarks.count, 3, "Recork does not erase CrackMarks")

        do {
            _ = try well.crack(RailSeedIDs.gin, dayKey: 20260917)
            XCTFail("already seated")
        } catch WellFault.alreadySeated {
        }

        do {
            _ = try well.recork(RailSeedIDs.campari)
            XCTFail("already backbar")
        } catch WellFault.notOnRail {
        }

        var dryWell = WellDocument.empty
        let dry = try dryWell.pourWell(from: book, dayKey: 20260917)
        XCTAssertEqual(dry.kind, .dry)
        XCTAssertTrue(dryWell.bottles.isEmpty)
    }
}
