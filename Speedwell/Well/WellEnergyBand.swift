import SwiftUI

/// Energy band once on Surprise. Heavy Pour, recipe on the band, thick rule, then the list.
struct WellEnergyBand: View {
    var seated: Int
    var makeable: Int
    var title: String
    var line: String
    var pulse: Int

    @Environment(\.dynamicTypeSize) private var typeSize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(alignment: .leading, spacing: WellMeasure.space(1)) {
            HStack(alignment: .firstTextBaseline, spacing: WellMeasure.space(2)) {
                Text("POUR")
                    .font(WellType.verb(at: typeSize))
                    .foregroundStyle(WellPaint.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                Spacer(minLength: 0)
                VStack(alignment: .trailing, spacing: 0) {
                    Text(WellInk.integer(seated))
                        .font(WellType.headline)
                        .foregroundStyle(WellPaint.ink)
                        .monospacedDigit()
                        .lineLimit(1)
                    Text("seated")
                        .font(WellType.micro)
                        .foregroundStyle(WellPaint.ink)
                }
            }

            Text(title)
                .font(WellType.title)
                .foregroundStyle(WellPaint.ink)
                .lineLimit(2)
                .minimumScaleFactor(0.7)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(line)
                .font(WellType.body)
                .foregroundStyle(WellPaint.ink)
                .lineLimit(2)

            HStack(spacing: WellMeasure.space(1)) {
                Text(WellInk.integer(makeable))
                    .font(WellType.micro)
                    .foregroundStyle(WellPaint.ink)
                    .monospacedDigit()
                    .lineLimit(1)
                Text("makeable")
                    .font(WellType.micro)
                    .foregroundStyle(WellPaint.ink)
            }

            RailWellShape(seated: seated)
                .fill(WellPaint.ink)
                .frame(maxWidth: .infinity, minHeight: WellMeasure.space(14), maxHeight: WellMeasure.space(16))
                .scaleEffect(reduceMotion ? 1 : (pulse % 2 == 0 ? 1 : 1.03))
                .animation(WellPulse.spring(reduceMotion: reduceMotion), value: pulse)
                .accessibilityHidden(true)
        }
        .padding(.horizontal, WellMeasure.space(2))
        .padding(.top, WellMeasure.space(2))
        .padding(.bottom, WellMeasure.space(2))
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            ZStack {
                WellPaint.accent
                Image("spw_HeaderDecor")
                    .resizable()
                    .scaledToFill()
                    .opacity(0.28)
                    .accessibilityHidden(true)
                Rectangle()
                    .fill(.thinMaterial)
                    .opacity(0.4)
            }
            .ignoresSafeArea(edges: .top)
            .clipped()
        }
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(WellPaint.ink)
                .frame(height: WellMeasure.rule)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "Pour. \(title). \(WellInk.integer(seated)) seated. \(WellInk.integer(makeable)) makeable."
        )
    }
}
