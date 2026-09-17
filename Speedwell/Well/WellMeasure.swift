import SwiftUI

/// Spacing, radii, and motion. One 8pt grid. Cards 16pt, chips 10pt. Never a bare radius in a view.
enum WellMeasure {
    static let unit: CGFloat = 8

    static func space(_ steps: Int) -> CGFloat {
        unit * CGFloat(steps)
    }

    static var card: CGFloat { 16 }
    static var chip: CGFloat { 10 }
    static var hit: CGFloat { 44 }
    static var rule: CGFloat { 4 }
    static var pressScale: CGFloat { 0.97 }
    static var ease: Double { 0.25 }
    static var springResponse: Double { 0.4 }
    static var springDamping: Double { 0.8 }
    static var spinnerGate: Duration { .milliseconds(150) }
}
