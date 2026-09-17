import SwiftUI

/// SF Pro via Font.system. Six steps. Heavyweight short verbs. Never Font.custom, never below 12pt.
enum WellType {
    static var display: Font { .system(.title, design: .default).weight(.black) }
    static var title: Font { .system(.title2, design: .default).weight(.heavy) }
    static var headline: Font { .system(.headline, design: .default).weight(.bold) }
    static var body: Font { .system(.body, design: .default) }
    static var caption: Font { .system(.subheadline, design: .default) }
    static var micro: Font { .system(.caption, design: .default).monospacedDigit() }

    static func verb(at size: DynamicTypeSize) -> Font {
        size.isAccessibilitySize ? title : display
    }
}
