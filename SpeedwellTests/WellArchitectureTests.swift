import XCTest
@testable import Speedwell

final class WellArchitectureTests: XCTestCase {
    func test_railADT_onlyBackbarOrSeated() throws {
        let well = WellDocument.seededRail()
        for bottle in well.bottles {
            switch bottle.seat {
            case .backbar, .seated:
                break
            }
        }
        XCTAssertEqual(well.rail.bottles.filter { $0.seat == .seated }.count, well.rail.bottles.count)
        XCTAssertTrue(well.bottles.contains { $0.seat == .backbar })
        XCTAssertTrue(well.bottles.contains { $0.seat == .seated })

        let payload = Data(#"{"id":"B1111111-1111-4111-8111-111111111111","name":"Gin","kind":"gin","seat":"cellar"}"#.utf8)
        XCTAssertThrowsError(try JSONDecoder().decode(Bottle.self, from: payload))

        let data = try JSONEncoder().encode(well)
        let object = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
        XCTAssertEqual(object["schemaVersion"] as? Int, 1)
        XCTAssertNil(object["makeable"])
        XCTAssertNil(object["makeableRecipes"])
        XCTAssertNil(object["rail"])
        XCTAssertNotNil(object["bottles"])
        XCTAssertNotNil(object["crackMarks"])
        XCTAssertNotNil(object["pourMarks"])
        XCTAssertNotNil(object["pinnedRecipeIds"])
    }

    func test_dayKeyUsesStartOfDay() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let date = Date(timeIntervalSince1970: 1_704_067_200)
        XCTAssertEqual(WellDay.key(date, calendar: calendar), 20240101)
    }
}
