import Foundation

/// Role: Assigned desk cellar_window formula. Vintage plus peak window, shifted by cellar temperature. Not a wine rack on home.
enum PeakBand: String, Sendable, Equatable {
    case young
    case approaching
    case ready
    case holding
    case pastPeak
}

enum PeakWindow {
    static func tempFactor(cellarC: Double) -> Double {
        (cellarC - 13) * 0.5
    }

    static func agedYears(vintage: Int, year: Int, cellarC: Double) -> Double {
        Double(year - vintage) + tempFactor(cellarC: cellarC)
    }

    static func band(vintage: Int, peakStart: Int, peakEnd: Int, year: Int, cellarC: Double) -> PeakBand {
        let age = agedYears(vintage: vintage, year: year, cellarC: cellarC)
        let start = Double(peakStart)
        let end = Double(peakEnd)
        if age < start - 1 { return .young }
        if age < start { return .approaching }
        if age < end { return .ready }
        if age < end + 1 { return .holding }
        return .pastPeak
    }
}
