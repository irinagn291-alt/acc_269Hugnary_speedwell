import SwiftUI

/// Twist screen. Backbar until Crack seats the bottle. Recork lifts it. Plus a Crack surface on Surprise.
struct CrackStage: View {
    @Environment(WellBooth.self) private var session
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Group {
            if let fault = session.barFault, session.barEmpty {
                WellFaultCutout(
                    headline: "Rail failed.",
                    line: fault,
                    retry: { session.retryBar() }
                )
            } else if session.barEmpty {
                WellCutout(
                    artName: "spw_TwistHero",
                    headline: "The bar is empty.",
                    line: "Add a bottle, then crack it onto the rail.",
                    verb: "Add a bottle",
                    action: { session.present(.bar) }
                )
            } else {
                populated
            }
        }
        .background(WellPaint.background.ignoresSafeArea())
        .navigationTitle("Crack")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .frame(minWidth: WellMeasure.hit, minHeight: WellMeasure.hit)
                        .contentShape(Rectangle())
                }
                .buttonStyle(WellPressStyle())
                .accessibilityLabel("Close")
            }
        }
    }

    private var populated: some View {
        List {
            Section {
                Image("spw_TwistHero")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: WellMeasure.space(24))
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(WellPaint.background)
                    .accessibilityHidden(true)
                Text("Backbar is owned and sealed. Crack seats it. Recork lifts it. Pour does not empty it.")
                    .font(WellType.body)
                    .foregroundStyle(WellPaint.ink)
                    .listRowBackground(WellPaint.surface)
            }

            if let fault = session.barFault {
                Section {
                    HStack {
                        Text(fault)
                            .font(WellType.body)
                            .foregroundStyle(WellPaint.ink)
                        Spacer()
                        Button("Retry") { session.retryBar() }
                            .buttonStyle(WellChipStyle(filled: true))
                    }
                    .listRowBackground(WellPaint.surface)
                }
            }

            if session.backbar.isEmpty {
                Section {
                    Text("Every owned bottle is seated.")
                        .font(WellType.body)
                        .foregroundStyle(WellPaint.ink)
                        .frame(minHeight: WellMeasure.hit)
                        .listRowBackground(WellPaint.surface)
                } header: {
                    Text("Backbar")
                        .font(WellType.caption)
                        .foregroundStyle(WellPaint.ink)
                }
            } else {
                Section {
                    ForEach(session.backbar) { bottle in
                        HStack(spacing: WellMeasure.space(1)) {
                            Image("spw_SealedCork")
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
                            Button("Crack") {
                                Task { await session.crack(bottle.id) }
                            }
                            .buttonStyle(WellChipStyle(filled: true))
                            .disabled(session.verbBusy)
                            .accessibilityLabel("Crack \(bottle.name)")
                        }
                        .frame(minHeight: WellMeasure.hit)
                        .listRowBackground(WellPaint.surface)
                    }
                } header: {
                    Text("Backbar")
                        .font(WellType.caption)
                        .foregroundStyle(WellPaint.ink)
                }
            }

            if !session.seated.isEmpty {
                Section {
                    ForEach(session.seated) { bottle in
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
                            Button("Recork") {
                                Task { await session.recork(bottle.id) }
                            }
                            .buttonStyle(WellChipStyle(filled: false))
                            .disabled(session.verbBusy)
                            .accessibilityLabel("Recork \(bottle.name)")
                        }
                        .frame(minHeight: WellMeasure.hit)
                        .listRowBackground(WellPaint.surface)
                    }
                } header: {
                    Text("Seated")
                        .font(WellType.caption)
                        .foregroundStyle(WellPaint.ink)
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(WellPaint.background)
        .contentMargins(.bottom, WellMeasure.space(3), for: .scrollContent)
        .animation(WellPulse.spring(reduceMotion: reduceMotion), value: session.commitPulse)
    }
}
