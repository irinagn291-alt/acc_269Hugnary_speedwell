import Foundation

/// Display formatters. Round only here. Numbers never interpolate as raw digits.
enum WellInk {
    static func integer(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "0"
    }

    static func kind(_ kind: String) -> String {
        switch kind {
        case "triple_sec":
            return "Triple sec"
        case "coffee_liqueur":
            return "Coffee liqueur"
        default:
            return kind.replacingOccurrences(of: "_", with: " ").localizedCapitalized
        }
    }

    static func seat(_ seat: RailSeat) -> String {
        switch seat {
        case .backbar:
            return "Backbar"
        case .seated:
            return "Seated"
        }
    }

    static func fault(_ error: Error) -> String {
        guard let fault = error as? WellFault else {
            return "Well failed. Try again."
        }
        switch fault {
        case .unknownBottle:
            return "That bottle is gone."
        case .alreadySeated:
            return "Already seated."
        case .notOnRail:
            return "Not on the rail."
        case .emptyName:
            return "Name is empty."
        case .emptyKind:
            return "Kind is empty."
        case .nothingMakeable:
            return "Nothing makeable. Crack another bottle."
        }
    }
}
