import Foundation

/// Role: Tonight's speed rail. Derived from currently Seated bottles. Never stored as a second list.
struct Rail: Sendable, Equatable {
    var bottles: [Bottle]

    var isEmpty: Bool { bottles.isEmpty }

    var kinds: Set<String> {
        Set(bottles.map(\.kind))
    }
}
