import XCTest
@testable import Speedwell

final class PeakWindowTests: XCTestCase {
    func test_tempFactorAndPeakBands() {
        XCTAssertEqual(PeakWindow.tempFactor(cellarC: 13), 0)
        XCTAssertEqual(PeakWindow.tempFactor(cellarC: 15), 1)
        XCTAssertEqual(PeakWindow.tempFactor(cellarC: 11), -1)

        XCTAssertEqual(
            PeakWindow.band(vintage: 2010, peakStart: 8, peakEnd: 15, year: 2014, cellarC: 13),
            .young
        )
        XCTAssertEqual(
            PeakWindow.band(vintage: 2010, peakStart: 8, peakEnd: 15, year: 2017, cellarC: 13),
            .approaching
        )
        XCTAssertEqual(
            PeakWindow.band(vintage: 2010, peakStart: 8, peakEnd: 15, year: 2020, cellarC: 13),
            .ready
        )
        XCTAssertEqual(
            PeakWindow.band(vintage: 2010, peakStart: 8, peakEnd: 15, year: 2025, cellarC: 13),
            .holding
        )
        XCTAssertEqual(
            PeakWindow.band(vintage: 2010, peakStart: 8, peakEnd: 15, year: 2028, cellarC: 13),
            .pastPeak
        )

        let warmer = PeakWindow.band(vintage: 2010, peakStart: 8, peakEnd: 15, year: 2016, cellarC: 15)
        XCTAssertEqual(warmer, .approaching)
        XCTAssertEqual(PeakWindow.agedYears(vintage: 2010, year: 2016, cellarC: 15), 7)
    }
}
