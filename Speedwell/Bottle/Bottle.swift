import Foundation

/// Role: One owned bottle on the well. Adding writes Backbar. Crack seats it. Recork returns Backbar. Pour does not empty it.
struct Bottle: Identifiable, Codable, Sendable, Equatable, Hashable {
    let id: UUID
    var name: String
    var kind: String
    var seat: RailSeat

    init(id: UUID = UUID(), name: String, kind: String, seat: RailSeat = .backbar) {
        self.id = id
        self.name = name
        self.kind = kind
        self.seat = seat
    }
}
