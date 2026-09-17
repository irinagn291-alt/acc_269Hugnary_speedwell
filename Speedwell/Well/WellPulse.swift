import SwiftUI
import UIKit

/// One haptic on a successful Pour, Crack, or Recork. None on presenting a sheet.
enum WellPulse {
    @MainActor
    static func commit() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    static func spring(reduceMotion: Bool) -> Animation {
        if reduceMotion {
            return .easeOut(duration: WellMeasure.ease)
        }
        return .spring(response: WellMeasure.springResponse, dampingFraction: WellMeasure.springDamping)
    }

    static func ease() -> Animation {
        .easeOut(duration: WellMeasure.ease)
    }
}

/// Primary Pour. Filled capsule, thick ink border, default / pressed / disabled / loading.
struct PourCapsuleStyle: ButtonStyle {
    var isLoading: Bool

    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            configuration.label
                .opacity(isLoading ? 0 : 1)
            if isLoading {
                ProgressView()
                    .tint(WellPaint.surface)
                    .accessibilityLabel("Pouring")
            }
        }
        .font(WellType.headline)
        .foregroundStyle(isEnabled ? WellPaint.surface : WellPaint.surface.opacity(0.8))
        .frame(maxWidth: .infinity, minHeight: WellMeasure.hit)
        .padding(.horizontal, WellMeasure.space(2))
        .background(isEnabled ? WellPaint.accent : WellPaint.muted)
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(WellPaint.ink.opacity(isEnabled ? 1 : 0.35), lineWidth: WellMeasure.rule)
        )
        .scaleEffect(scale(configuration.isPressed))
        .opacity(reduceMotion && configuration.isPressed ? 0.82 : 1)
        .animation(WellPulse.ease(), value: configuration.isPressed)
        .contentShape(Capsule())
    }

    private func scale(_ pressed: Bool) -> CGFloat {
        if reduceMotion || isLoading { return 1 }
        return pressed ? WellMeasure.pressScale : 1
    }
}

/// Filled capsule without the Pour rule. Crack, Continue, empty-state verbs.
struct WellFillStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(WellType.headline)
            .foregroundStyle(WellPaint.surface)
            .frame(maxWidth: .infinity, minHeight: WellMeasure.hit)
            .padding(.horizontal, WellMeasure.space(2))
            .background(isEnabled ? WellPaint.accent : WellPaint.muted)
            .clipShape(Capsule())
            .scaleEffect(reduceMotion ? 1 : (configuration.isPressed ? WellMeasure.pressScale : 1))
            .opacity(reduceMotion && configuration.isPressed ? 0.82 : 1)
            .animation(WellPulse.ease(), value: configuration.isPressed)
            .contentShape(Capsule())
    }
}

/// Recork and quiet sheet actions. Not the destructive variant.
struct WellQuietStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(WellType.headline)
            .foregroundStyle(isEnabled ? WellPaint.ink : WellPaint.muted)
            .frame(maxWidth: .infinity, minHeight: WellMeasure.hit)
            .padding(.horizontal, WellMeasure.space(2))
            .background(.regularMaterial)
            .background(WellPaint.surface)
            .clipShape(Capsule())
            .scaleEffect(reduceMotion ? 1 : (configuration.isPressed ? WellMeasure.pressScale : 1))
            .opacity(reduceMotion && configuration.isPressed ? 0.82 : 1)
            .animation(WellPulse.ease(), value: configuration.isPressed)
            .contentShape(Capsule())
    }
}

/// Row verbs: Crack, Recork, Pin. Chip radius. Not the Pour capsule.
struct WellChipStyle: ButtonStyle {
    var filled: Bool = false

    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(WellType.headline)
            .foregroundStyle(labelColor)
            .padding(.horizontal, WellMeasure.space(2))
            .frame(minWidth: WellMeasure.hit, minHeight: WellMeasure.hit)
            .background { chipFill }
            .clipShape(RoundedRectangle(cornerRadius: WellMeasure.chip, style: .continuous))
            .scaleEffect(reduceMotion ? 1 : (configuration.isPressed ? WellMeasure.pressScale : 1))
            .opacity(reduceMotion && configuration.isPressed ? 0.82 : 1)
            .animation(WellPulse.ease(), value: configuration.isPressed)
            .contentShape(RoundedRectangle(cornerRadius: WellMeasure.chip, style: .continuous))
    }

    private var labelColor: Color {
        if filled {
            return WellPaint.surface
        }
        return isEnabled ? WellPaint.ink : WellPaint.muted
    }

    @ViewBuilder
    private var chipFill: some View {
        if filled {
            isEnabled ? WellPaint.accent : WellPaint.muted
        } else {
            ZStack {
                WellPaint.surface
                Rectangle().fill(.thinMaterial)
            }
        }
    }
}

/// Icon chrome and well-link hits. Pressed state without a second radius language.
struct WellPressStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(reduceMotion ? 1 : (configuration.isPressed ? WellMeasure.pressScale : 1))
            .opacity(configuration.isPressed ? 0.82 : 1)
            .animation(WellPulse.ease(), value: configuration.isPressed)
    }
}

/// resetAllData only. Does not wear accent.
struct WellDestroyStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(WellType.headline)
            .foregroundStyle(isEnabled ? WellPaint.ink : WellPaint.muted)
            .frame(maxWidth: .infinity, minHeight: WellMeasure.hit)
            .padding(.horizontal, WellMeasure.space(2))
            .background(.regularMaterial)
            .background(WellPaint.surface)
            .clipShape(Capsule())
            .scaleEffect(reduceMotion ? 1 : (configuration.isPressed ? WellMeasure.pressScale : 1))
            .opacity(reduceMotion && configuration.isPressed ? 0.82 : 1)
            .animation(WellPulse.ease(), value: configuration.isPressed)
            .contentShape(Capsule())
    }
}

extension View {
    func wellSurface() -> some View {
        background(WellPaint.surface)
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: WellMeasure.card, style: .continuous))
    }

    func wellChip() -> some View {
        background(WellPaint.surface)
            .clipShape(RoundedRectangle(cornerRadius: WellMeasure.chip, style: .continuous))
    }
}
