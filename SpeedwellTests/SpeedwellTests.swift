import XCTest
@testable import Speedwell

final class SpeedwellTests: XCTestCase {
    func test_appModuleImports() {
        XCTAssertEqual(String(describing: SpeedwellApp.self), "SpeedwellApp")
        XCTAssertEqual(RecipeCatalog.railBook.count, 12)
        XCTAssertEqual(WellProbe.unusedSearchPath, "/cgi/search.pl")
    }
}
