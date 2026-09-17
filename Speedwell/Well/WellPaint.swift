import SwiftUI

/// Named colours in Assets.xcassets. Views use these tokens, never a raw hex.
/// background #F5FAF8, surface #FDFEFE, ink #183931, accent #2CBA96, muted #597870
enum WellPaint {
    static var background: Color { Color("wellBackground") }
    static var surface: Color { Color("wellSurface") }
    static var ink: Color { Color("wellInk") }
    static var accent: Color { Color("wellAccent") }
    static var muted: Color { Color("wellMuted") }
}
