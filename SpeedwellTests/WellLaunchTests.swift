import XCTest
@testable import Speedwell

final class WellLaunchTests: XCTestCase {
    func test_readsOnceAfterOnboarding() {
        var consumed = false
        XCTAssertNil(
            WellLinks.consume(
                arguments: ["-ReviewScreen", "log"],
                onboardingComplete: false,
                consumed: &consumed
            )
        )
        XCTAssertFalse(consumed)

        let first = WellLinks.consume(
            arguments: ["app", "-ReviewScreen", "log"],
            onboardingComplete: true,
            consumed: &consumed
        )
        XCTAssertEqual(first, .log)
        XCTAssertEqual(first?.job, .sheet(.bar))
        XCTAssertTrue(consumed)
        XCTAssertNil(
            WellLinks.consume(
                arguments: ["-ReviewScreen", "goals"],
                onboardingComplete: true,
                consumed: &consumed
            )
        )
    }

    func test_threeKeysAreDistinctScreens() {
        XCTAssertEqual(WellPane.today.rawValue, "today")
        XCTAssertEqual(WellPane.log.rawValue, "log")
        XCTAssertEqual(WellPane.goals.rawValue, "goals")
        XCTAssertNotEqual(WellPane.today, WellPane.log)
        XCTAssertNotEqual(WellPane.log, WellPane.goals)
        XCTAssertNotEqual(WellPane.today, WellPane.goals)
        XCTAssertEqual(WellPane.today.job, .surprise)
        XCTAssertEqual(WellPane.log.job, .sheet(.bar))
        XCTAssertEqual(WellPane.goals.job, .sheet(.settings))
        XCTAssertNotEqual(WellPane.today.job, WellPane.log.job)
        XCTAssertNotEqual(WellPane.log.job, WellPane.goals.job)
        XCTAssertNotEqual(WellPane.today.job, WellPane.goals.job)
        XCTAssertFalse(WellSheet.allCases.map(\.rawValue).contains("game"))
        XCTAssertFalse(WellSheet.allCases.map(\.rawValue).contains("sweep"))

        var consumed = false
        XCTAssertEqual(
            WellLinks.consume(
                arguments: ["-ReviewScreen", "today"],
                onboardingComplete: true,
                consumed: &consumed
            ),
            .today
        )
        consumed = false
        XCTAssertEqual(
            WellLinks.consume(
                arguments: ["-ReviewScreen", "goals"],
                onboardingComplete: true,
                consumed: &consumed
            ),
            .goals
        )
    }

    func test_extraCoverSlugsOpenNamedScreens() {
        XCTAssertEqual(WellPane.parse("surprise")?.job, .surprise)
        XCTAssertEqual(WellPane.parse("bar")?.job, .sheet(.bar))
        XCTAssertEqual(WellPane.parse("discover")?.job, .sheet(.discover))
        XCTAssertEqual(WellPane.parse("favorites")?.job, .sheet(.favorites))
        XCTAssertEqual(WellPane.parse("settings")?.job, .sheet(.settings))
        XCTAssertEqual(WellPane.parse("home")?.job, .surprise)
        XCTAssertNotEqual(WellPane.parse("discover")?.job, WellPane.today.job)
        XCTAssertNotEqual(WellPane.parse("favorites")?.job, WellPane.log.job)
        XCTAssertNotEqual(WellPane.parse("discover")?.job, WellPane.goals.job)
        XCTAssertNotEqual(WellPane.parse("favorites")?.job, WellPane.goals.job)

        var consumed = false
        XCTAssertEqual(
            WellLinks.consume(
                arguments: ["-ReviewScreen", "discover"],
                onboardingComplete: true,
                consumed: &consumed
            ),
            .discover
        )
        consumed = false
        XCTAssertEqual(
            WellLinks.consume(
                arguments: ["-ReviewScreen", "favorites"],
                onboardingComplete: true,
                consumed: &consumed
            ),
            .favorites
        )
        consumed = false
        XCTAssertEqual(
            WellLinks.consume(
                arguments: ["-ReviewScreen", "bar"],
                onboardingComplete: true,
                consumed: &consumed
            ),
            .bar
        )
        consumed = false
        XCTAssertEqual(
            WellLinks.consume(
                arguments: ["-ReviewScreen", "settings"],
                onboardingComplete: true,
                consumed: &consumed
            ),
            .settings
        )
        XCTAssertEqual(
            WellLinks.parse(arguments: ProcessInfo.processInfo.arguments),
            WellLinks.parse()
        )
        XCTAssertTrue(WellLinks.isReviewLaunch(arguments: ["-ReviewScreen", "today"]))
    }

    func test_unknownKeyIsIgnored() {
        var consumed = false
        XCTAssertNil(
            WellLinks.consume(
                arguments: ["-ReviewScreen", "aura"],
                onboardingComplete: true,
                consumed: &consumed
            )
        )
        XCTAssertTrue(consumed)
    }

    func test_speedwellURLsRouteJobs() throws {
        XCTAssertEqual(WellLinks.parseURL(try XCTUnwrap(URL(string: "speedwell://surprise"))), .surprise)
        XCTAssertEqual(WellLinks.parseURL(try XCTUnwrap(URL(string: "speedwell://pour"))), .pour)
        XCTAssertEqual(WellLinks.parseURL(try XCTUnwrap(URL(string: "speedwell://bar"))), .sheet(.bar))
        XCTAssertEqual(WellLinks.parseURL(try XCTUnwrap(URL(string: "speedwell://discover"))), .sheet(.discover))
        XCTAssertEqual(WellLinks.parseURL(try XCTUnwrap(URL(string: "speedwell://favorites"))), .sheet(.favorites))
        XCTAssertEqual(WellLinks.parseURL(try XCTUnwrap(URL(string: "speedwell://settings"))), .sheet(.settings))
        XCTAssertNil(WellLinks.parseURL(try XCTUnwrap(URL(string: "https://speedwell-rail.pro/contact-us"))))
    }
}
