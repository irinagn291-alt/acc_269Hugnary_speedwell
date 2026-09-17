import SwiftUI

/// Three-page cover. Skip writes the completion flag. Continue is always full width.
struct OnboardingCover: View {
    @Environment(WellBooth.self) private var session
    @State private var page = 0

    private let pages: [(art: String, headline: String, line: String)] = [
        (
            "spw_Onboarding1",
            "Tonight's well",
            "Pour one cocktail from bottles already on your rail."
        ),
        (
            "spw_Onboarding2",
            "Crack, then pour",
            "Crack seats a bottle. Surprise ignores sealed stock."
        ),
        (
            "spw_Onboarding3",
            "Seat what you mix",
            "Recork lifts a bottle. Pin a recipe you will make again."
        ),
    ]

    var body: some View {
        VStack(spacing: 0) {
            Text(pages[page].headline)
                .font(WellType.title)
                .foregroundStyle(WellPaint.ink)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, WellMeasure.space(2))
                .padding(.top, WellMeasure.space(3))
            Text(pages[page].line)
                .font(WellType.body)
                .foregroundStyle(WellPaint.ink)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, WellMeasure.space(2))
                .padding(.top, WellMeasure.space(1))

            ZStack {
                WellPaint.surface
                Image(pages[page].art)
                    .resizable()
                    .scaledToFit()
                    .padding(WellMeasure.space(2))
                    .accessibilityHidden(true)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: WellMeasure.card, style: .continuous))
            .padding(.horizontal, WellMeasure.space(2))
            .padding(.top, WellMeasure.space(2))

            HStack(spacing: WellMeasure.space(1)) {
                ForEach(pages.indices, id: \.self) { index in
                    Capsule()
                        .fill(index == page ? WellPaint.accent : WellPaint.muted.opacity(0.35))
                        .frame(width: index == page ? WellMeasure.space(3) : WellMeasure.unit, height: WellMeasure.unit)
                        .accessibilityHidden(true)
                }
            }
            .padding(.vertical, WellMeasure.space(2))

            Button(page >= pages.count - 1 ? "Continue" : "Next") {
                advance()
            }
            .buttonStyle(WellFillStyle())
            .padding(.horizontal, WellMeasure.space(2))

            Button("Skip") {
                Task { await session.finishOnboarding() }
            }
            .buttonStyle(WellQuietStyle())
            .padding(.horizontal, WellMeasure.space(2))
            .padding(.top, WellMeasure.space(1))
            .padding(.bottom, WellMeasure.space(2))
        }
        .background(WellPaint.background.ignoresSafeArea())
    }

    private func advance() {
        if page >= pages.count - 1 {
            Task { await session.finishOnboarding() }
        } else {
            page += 1
        }
    }
}
