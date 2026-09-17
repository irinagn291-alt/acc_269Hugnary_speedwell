import SwiftUI

/// Tonight's well. Home is the mechanic: Pour samples seated bottles. Not a recipe list.
struct SurpriseView: View {
    @Environment(WellBooth.self) private var session
    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        Group {
            if let fault = session.bootFault, session.barEmpty, !session.isReady {
                WellFaultCutout(
                    headline: "Well did not open.",
                    line: fault,
                    retry: { Task { await session.retryBoot() } }
                )
            } else if let fault = session.surpriseFault, session.barEmpty {
                WellFaultCutout(
                    headline: "Well failed.",
                    line: fault,
                    retry: { session.retrySurprise() }
                )
            } else if session.barEmpty {
                emptyWell
            } else {
                populated
            }
        }
        .background(WellPaint.background.ignoresSafeArea())
        .safeAreaInset(edge: .bottom) {
            wellLinkStrip
        }
    }

    private var emptyWell: some View {
        VStack(alignment: .leading, spacing: 0) {
            WellEnergyBand(
                seated: 0,
                makeable: 0,
                title: "The bar is empty.",
                line: "Add a bottle, then pour.",
                pulse: session.commitPulse
            )
            Button("Add a bottle") {
                session.present(.bar)
            }
            .buttonStyle(WellFillStyle())
            .padding(.horizontal, WellMeasure.space(2))
            .padding(.top, WellMeasure.space(2))

            twistCue
                .padding(.horizontal, WellMeasure.space(2))
                .padding(.top, WellMeasure.space(2))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(WellPaint.background)
    }

    private var populated: some View {
        VStack(alignment: .leading, spacing: 0) {
            WellEnergyBand(
                seated: session.seated.count,
                makeable: session.makeable.count,
                title: bandTitle,
                line: "One cocktail from the rail.",
                pulse: session.commitPulse
            )

            if let fault = session.surpriseFault {
                faultBanner(fault)
                    .padding(.horizontal, WellMeasure.space(2))
                    .padding(.top, WellMeasure.space(2))
            }

            pourControl
                .padding(.horizontal, WellMeasure.space(2))
                .padding(.top, WellMeasure.space(2))

            chipRow
                .padding(.horizontal, WellMeasure.space(2))
                .padding(.top, WellMeasure.space(1))

            seatedRail
                .padding(.top, WellMeasure.space(2))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(WellPaint.background)
    }

    private var bandTitle: String {
        if let recipe = session.pouredRecipe {
            return recipe.name
        }
        if session.lastPourWasDry {
            return "Dry"
        }
        return "Tap Pour."
    }

    private var chipRow: some View {
        HStack(spacing: WellMeasure.space(1)) {
            if let recipe = session.pouredRecipe {
                Button {
                    Task { await session.togglePin(recipe.id) }
                } label: {
                    Text(session.isPinned(recipe.id) ? "Pinned" : "Pin")
                        .frame(minHeight: WellMeasure.hit)
                }
                .buttonStyle(WellChipStyle(filled: false))
                .disabled(session.verbBusy)
                .accessibilityLabel(session.isPinned(recipe.id) ? "Unpin recipe" : "Pin recipe")
            }

            Button {
                session.presentCrack()
            } label: {
                Text("Crack")
                    .frame(minHeight: WellMeasure.hit)
            }
            .buttonStyle(WellChipStyle(filled: false))
            .accessibilityLabel("Crack a bottle")

            Spacer(minLength: 0)
        }
    }

    private var pourControl: some View {
        Button {
            Task { await session.pourWell() }
        } label: {
            HStack(spacing: WellMeasure.space(1)) {
                Image("spw_ControlFace")
                    .resizable()
                    .scaledToFit()
                    .frame(width: WellMeasure.space(3), height: WellMeasure.space(3))
                    .accessibilityHidden(true)
                Text("Pour")
                    .font(WellType.verb(at: typeSize))
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
            }
            .frame(maxWidth: .infinity, minHeight: WellMeasure.hit)
            .contentShape(Capsule())
        }
        .buttonStyle(PourCapsuleStyle(isLoading: session.pourLoading))
        .disabled(session.verbBusy)
        .accessibilityLabel("Pour the well")
        .accessibilityHint("Samples one recipe whose bottles all sit on the rail.")
    }

    private var seatedRail: some View {
        VStack(alignment: .leading, spacing: WellMeasure.space(1)) {
            HStack(alignment: .firstTextBaseline) {
                Text("Seated")
                    .font(WellType.caption)
                    .foregroundStyle(WellPaint.ink)
                Spacer(minLength: 0)
                Text(WellInk.integer(session.seated.count))
                    .font(WellType.headline)
                    .foregroundStyle(WellPaint.ink)
                    .monospacedDigit()
                    .lineLimit(1)
            }
            .padding(.horizontal, WellMeasure.space(2))

            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    ForEach(session.seated) { bottle in
                        seatedRow(bottle)
                    }
                    if session.seated.isEmpty {
                        Text("No bottle on the rail. Crack one, or Pour writes Dry.")
                            .font(WellType.body)
                            .foregroundStyle(WellPaint.ink)
                            .padding(WellMeasure.space(2))
                            .frame(maxWidth: .infinity, minHeight: WellMeasure.hit, alignment: .leading)
                            .wellSurface()
                            .padding(.horizontal, WellMeasure.space(2))
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentMargins(.bottom, WellMeasure.space(1), for: .scrollContent)
        }
    }

    private func seatedRow(_ bottle: Bottle) -> some View {
        HStack(spacing: WellMeasure.space(1)) {
            Image("spw_RailBottle")
                .resizable()
                .scaledToFit()
                .frame(width: WellMeasure.space(5), height: WellMeasure.space(5))
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 0) {
                Text(bottle.name)
                    .font(WellType.body)
                    .foregroundStyle(WellPaint.ink)
                    .lineLimit(1)
                Text(WellInk.seat(bottle.seat))
                    .font(WellType.caption)
                    .foregroundStyle(WellPaint.ink)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            Text(WellInk.kind(bottle.kind))
                .font(WellType.caption)
                .foregroundStyle(WellPaint.ink)
                .lineLimit(1)
        }
        .padding(.horizontal, WellMeasure.space(2))
        .frame(maxWidth: .infinity, minHeight: WellMeasure.hit, alignment: .leading)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(bottle.name), \(WellInk.seat(bottle.seat))")
    }

    private var twistCue: some View {
        VStack(alignment: .leading, spacing: WellMeasure.space(1)) {
            Image("spw_TwistHero")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: WellMeasure.space(16))
                .accessibilityHidden(true)
            Text("Backbar stays sealed.")
                .font(WellType.headline)
                .foregroundStyle(WellPaint.ink)
            Text("Crack seats a bottle on the rail. Pour does not empty it.")
                .font(WellType.body)
                .foregroundStyle(WellPaint.ink)
            Button("Crack then pour") {
                session.presentCrack()
            }
            .buttonStyle(WellQuietStyle())
            .accessibilityLabel("Open crack then pour")
        }
        .padding(WellMeasure.space(2))
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background {
            Image("spw_CardBackdrop")
                .resizable()
                .scaledToFill()
                .accessibilityHidden(true)
        }
        .clipped()
        .wellSurface()
    }

    private var wellLinkStrip: some View {
        HStack(spacing: 0) {
            linkButton("Bar", symbol: "cabinet", action: { session.present(.bar) })
            linkButton("Discover", symbol: "list.bullet", action: { session.present(.discover) })
            linkButton("Favorites", symbol: "bookmark", action: { session.present(.favorites) })
            linkButton("Settings", symbol: "gearshape", action: { session.present(.settings) })
        }
        .padding(.horizontal, WellMeasure.space(1))
        .padding(.top, WellMeasure.space(1))
        .padding(.bottom, WellMeasure.space(1))
        .background(.regularMaterial)
        .background(WellPaint.surface)
    }

    private func linkButton(_ title: String, symbol: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 0) {
                Image(systemName: symbol)
                    .font(WellType.headline)
                Text(title)
                    .font(WellType.micro)
                    .lineLimit(1)
            }
            .foregroundStyle(WellPaint.ink)
            .frame(maxWidth: .infinity, minHeight: WellMeasure.hit)
            .contentShape(Rectangle())
        }
        .buttonStyle(WellPressStyle())
        .accessibilityLabel(title)
    }

    private func faultBanner(_ text: String) -> some View {
        HStack(alignment: .center, spacing: WellMeasure.space(1)) {
            Text(text)
                .font(WellType.body)
                .foregroundStyle(WellPaint.ink)
                .frame(maxWidth: .infinity, alignment: .leading)
            Button("Retry") {
                session.retrySurprise()
            }
            .buttonStyle(WellChipStyle(filled: true))
        }
        .padding(WellMeasure.space(2))
        .wellSurface()
    }
}
