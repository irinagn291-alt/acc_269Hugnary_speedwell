import XCTest
@testable import Speedwell

private actor ScriptedCarrier: WellCarrying {
    private var results: [Result<(Data, URLResponse), Error>]
    private var requests: [URLRequest] = []

    init(results: [Result<(Data, URLResponse), Error>]) {
        self.results = results
    }

    func carry(_ request: URLRequest) async throws -> (Data, URLResponse) {
        requests.append(request)
        guard !results.isEmpty else { throw URLError(.cannotConnectToHost) }
        return try results.removeFirst().get()
    }

    func recordedRequests() -> [URLRequest] {
        requests
    }
}

final class WellProbeTests: XCTestCase {
    private let url = URL(string: "https://speedwell-rail.pro/probe")!

    func test_leftoverSearchIsUnusedAndDoesNotHop() async {
        let hop = ScriptedCarrier(results: [
            .success((Data("{\"status\":1}".utf8), http(200))),
        ])
        let probe = WellProbe(carrier: hop)
        do {
            try await probe.leftoverSearch("negroni")
            XCTFail("leftover search must not run")
        } catch {
            XCTAssertEqual(error as? WellWire, .leftoverSearch)
        }
        let count = await hop.recordedRequests().count
        XCTAssertEqual(count, 0)
        XCTAssertEqual(WellProbe.unusedSearchPath, "/cgi/search.pl")
        XCTAssertEqual(WellProbe.userAgent, "Speedwell/1.0 (iOS; +https://speedwell-rail.pro)")
        XCTAssertEqual(WellProbe.contactURL.absoluteString, "https://speedwell-rail.pro/contact-us")
        XCTAssertFalse(WellProbe.userAgent.contains("OpenFoodFacts"))
    }

    func test_setsUserAgentOnEveryRequest() async throws {
        let hop = ScriptedCarrier(results: [
            .success((Data("{\"status\":1}".utf8), http(200))),
        ])
        let probe = WellProbe(carrier: hop)
        _ = try await probe.readJSON(WellProbeDTO.self, from: url)
        let request = await hop.recordedRequests().first
        XCTAssertEqual(request?.value(forHTTPHeaderField: "User-Agent"), WellProbe.userAgent)
        XCTAssertEqual(request?.timeoutInterval, 15)
    }

    func test_retriesTransientTransportOnce() async throws {
        let hop = ScriptedCarrier(results: [
            .failure(URLError(.timedOut)),
            .success((Data("{\"status\":1}".utf8), http(200))),
        ])
        let probe = WellProbe(carrier: hop)
        let dto = try await probe.readJSON(WellProbeDTO.self, from: url)
        XCTAssertEqual(dto.status, 1)
        let count = await hop.recordedRequests().count
        XCTAssertEqual(count, 2)
    }

    func test_doesNotRetry404() async {
        let hop = ScriptedCarrier(results: [
            .success((Data(), http(404))),
            .success((Data("{\"status\":1}".utf8), http(200))),
        ])
        let probe = WellProbe(carrier: hop)
        do {
            _ = try await probe.readJSON(WellProbeDTO.self, from: url)
            XCTFail("expected missing")
        } catch {
            XCTAssertEqual(error as? WellWire, .missing)
        }
        let count = await hop.recordedRequests().count
        XCTAssertEqual(count, 1)
    }

    func test_statusZeroIsMissing() async {
        let hop = ScriptedCarrier(results: [
            .success((Data("{\"status\":\"0\"}".utf8), http(200))),
        ])
        let probe = WellProbe(carrier: hop)
        do {
            _ = try await probe.readProbe(from: url)
            XCTFail("expected missing")
        } catch {
            XCTAssertEqual(error as? WellWire, .missing)
        }
    }

    func test_malformedJSONIsGarbled() async {
        let hop = ScriptedCarrier(results: [
            .success((Data("{".utf8), http(200))),
        ])
        let probe = WellProbe(carrier: hop)
        do {
            _ = try await probe.readJSON(WellProbeDTO.self, from: url)
            XCTFail("expected garbled")
        } catch {
            XCTAssertEqual(error as? WellWire, .garbled)
        }
    }

    private func http(_ status: Int) -> HTTPURLResponse {
        HTTPURLResponse(
            url: url,
            statusCode: status,
            httpVersion: nil,
            headerFields: nil
        )!
    }
}
