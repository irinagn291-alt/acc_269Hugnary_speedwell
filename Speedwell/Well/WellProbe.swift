import Foundation

/// Role: Typed transport failures. Leftover cgi search.pl stays unused. No remote catalog.
enum WellWire: Error, Equatable, Sendable {
    case leftoverSearch
    case missing
    case garbled
    case dropped
    case cancelled
}

/// Role: One HTTP hop. Tests inject this so leftover search never leaves the process.
protocol WellCarrying: Sendable {
    func carry(_ request: URLRequest) async throws -> (Data, URLResponse)
}

struct WellSession: WellCarrying {
    let session: URLSession

    init(session: URLSession) {
        self.session = session
    }

    init() {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.timeoutIntervalForRequest = 15
        configuration.timeoutIntervalForResource = 15
        configuration.httpAdditionalHeaders = ["User-Agent": WellProbe.userAgent]
        self.session = URLSession(configuration: configuration)
    }

    func carry(_ request: URLRequest) async throws -> (Data, URLResponse) {
        try await session.data(for: request)
    }
}

/// Role: DTO that mirrors a JSON object exactly. Never decoded into Recipe or Bottle.
struct WellProbeDTO: Decodable, Sendable {
    var status: Int?
    var label: String?

    enum CodingKeys: String, CodingKey {
        case status
        case label
    }

    init(status: Int?, label: String?) {
        self.status = status
        self.label = label
    }

    init(from decoder: Decoder) throws {
        let box = try decoder.container(keyedBy: CodingKeys.self)
        status = WellProbeNumber.int(box, forKey: .status)
        label = try box.decodeIfPresent(String.self, forKey: .label)
    }
}

enum WellProbeNumber {
    static func int<Key: CodingKey>(_ box: KeyedDecodingContainer<Key>, forKey key: Key) -> Int? {
        if let value = try? box.decode(Int.self, forKey: key) { return value }
        if let value = try? box.decode(Double.self, forKey: key) { return Int(value) }
        if let text = try? box.decode(String.self, forKey: key) { return Int(text) }
        return nil
    }
}

/// Role: Owns leftover unused search. Does not call cgi search pl. No remote catalog. Contact URL is a Settings link.
actor WellProbe {
    static let userAgent = "Speedwell/1.0 (iOS; +https://speedwell-rail.pro)"
    /// Programmer constant. The contact URL is fixed in SPEC.md.
    static let contactURL = URL(string: "https://speedwell-rail.pro/contact-us")!
    static let unusedSearchPath = "/cgi/search.pl"

    private let carrier: any WellCarrying
    private let decoder: JSONDecoder

    init(carrier: any WellCarrying) {
        self.carrier = carrier
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .useDefaultKeys
        self.decoder = decoder
    }

    init() {
        self.init(carrier: WellSession())
    }

    /// Leftover catalog search is unused. Never hits the network.
    func leftoverSearch(_ terms: String) async throws {
        _ = terms
        throw WellWire.leftoverSearch
    }

    func readJSON<DTO: Decodable & Sendable>(_ type: DTO.Type, from url: URL) async throws -> DTO {
        try Task.checkCancellation()
        let body = try await payload(for: request(for: url), allowRetry: true)
        do {
            return try decoder.decode(type, from: body)
        } catch is CancellationError {
            throw WellWire.cancelled
        } catch {
            throw WellWire.garbled
        }
    }

    func readProbe(from url: URL) async throws -> WellProbeDTO {
        let dto = try await readJSON(WellProbeDTO.self, from: url)
        if dto.status == 0 {
            throw WellWire.missing
        }
        return dto
    }

    private func request(for url: URL) -> URLRequest {
        var request = URLRequest(url: url, timeoutInterval: 15)
        request.setValue(Self.userAgent, forHTTPHeaderField: "User-Agent")
        return request
    }

    private func payload(for request: URLRequest, allowRetry: Bool) async throws -> Data {
        try Task.checkCancellation()
        do {
            return try await send(request)
        } catch let fault as WellWire {
            throw fault
        } catch is CancellationError {
            throw WellWire.cancelled
        } catch {
            if Self.isCancelled(error) { throw WellWire.cancelled }
            guard allowRetry, Self.isTransient(error) else { throw WellWire.dropped }
            return try await payload(for: request, allowRetry: false)
        }
    }

    private func send(_ request: URLRequest) async throws -> Data {
        try Task.checkCancellation()
        let (data, response) = try await carrier.carry(request)
        guard let http = response as? HTTPURLResponse else {
            throw WellWire.dropped
        }
        if http.statusCode == 404 {
            throw WellWire.missing
        }
        guard (200 ..< 300).contains(http.statusCode) else {
            throw WellWire.dropped
        }
        return data
    }

    private static func isTransient(_ error: Error) -> Bool {
        guard let urlError = error as? URLError else { return false }
        switch urlError.code {
        case .timedOut, .networkConnectionLost, .notConnectedToInternet,
             .cannotConnectToHost, .cannotFindHost, .dnsLookupFailed:
            return true
        default:
            return false
        }
    }

    private static func isCancelled(_ error: Error) -> Bool {
        if error is CancellationError { return true }
        return (error as? URLError)?.code == .cancelled
    }
}
