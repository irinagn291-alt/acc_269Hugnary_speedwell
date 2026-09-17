import SwiftUI

/// Full-page empty or error cutout. One headline, one line, bottom full-width verb.
struct WellCutout: View {
    var artName: String
    var headline: String
    var line: String
    var verb: String
    var action: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(headline)
                .font(WellType.title)
                .foregroundStyle(WellPaint.ink)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, WellMeasure.space(3))
            Text(line)
                .font(WellType.body)
                .foregroundStyle(WellPaint.ink)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, WellMeasure.space(1))

            ZStack {
                WellPaint.surface
                Image(artName)
                    .resizable()
                    .scaledToFit()
                    .padding(WellMeasure.space(2))
                    .accessibilityHidden(true)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: WellMeasure.card, style: .continuous))
            .padding(.top, WellMeasure.space(2))

            Button(verb, action: action)
                .buttonStyle(WellFillStyle())
                .padding(.top, WellMeasure.space(2))
                .padding(.bottom, WellMeasure.space(2))
        }
        .padding(.horizontal, WellMeasure.space(2))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(WellPaint.background)
    }
}

struct WellFaultCutout: View {
    var headline: String
    var line: String
    var retry: () -> Void

    var body: some View {
        WellCutout(
            artName: "spw_EmptyList",
            headline: headline,
            line: line,
            verb: "Retry",
            action: retry
        )
    }
}
