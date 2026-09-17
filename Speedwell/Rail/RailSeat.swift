import Foundation

/// Role: Closed algebraic seat on a Bottle. Backbar is owned and sealed. Seated sits on the Rail. A third role is a defect.
enum RailSeat: String, Codable, Sendable, Equatable, Hashable {
    case backbar
    case seated
}
