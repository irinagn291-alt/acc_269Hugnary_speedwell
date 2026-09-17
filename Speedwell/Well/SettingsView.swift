import SwiftUI

/// Reset the well, catalog credit, contact URL. ReviewScreen goals.
struct SettingsView: View {
    @Environment(WellBooth.self) private var session
    @Environment(\.dismiss) private var dismiss
    @State private var confirmReset = false

    var body: some View {
        Group {
            if let fault = session.settingsFault, session.barEmpty, session.document.pourMarks.isEmpty {
                WellFaultCutout(
                    headline: "Settings failed.",
                    line: fault,
                    retry: { session.retrySettings() }
                )
            } else {
                populated
            }
        }
        .background(WellPaint.background.ignoresSafeArea())
        .navigationTitle("Settings")
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
        .confirmationDialog(
            "Reset the well. Bottles, cracks, pours, and pins are removed.",
            isPresented: $confirmReset,
            titleVisibility: .visible
        ) {
            Button("Reset the well", role: .destructive) {
                Task { await session.resetAllData() }
            }
            Button("Cancel", role: .cancel) {}
        }
    }

    private var populated: some View {
        Form {
            if let fault = session.settingsFault {
                Section {
                    VStack(alignment: .leading, spacing: WellMeasure.space(1)) {
                        Text("Well recovered.")
                            .font(WellType.headline)
                            .foregroundStyle(WellPaint.ink)
                        Text(fault)
                            .font(WellType.body)
                            .foregroundStyle(WellPaint.ink)
                        Button("Retry") {
                            session.retrySettings()
                        }
                        .buttonStyle(WellFillStyle())
                    }
                    .listRowBackground(WellPaint.surface)
                }
            }

            Section {
                HStack(alignment: .firstTextBaseline) {
                    Text("Seated")
                        .font(WellType.body)
                        .foregroundStyle(WellPaint.ink)
                    Spacer(minLength: 0)
                    Text(WellInk.integer(session.seated.count))
                        .font(WellType.display)
                        .foregroundStyle(WellPaint.accent)
                        .monospacedDigit()
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                }
                .frame(minHeight: WellMeasure.hit)
                .listRowBackground(WellPaint.surface)
                summaryRow(label: "Bottles", value: WellInk.integer(session.document.bottles.count))
                summaryRow(label: "Cracks", value: WellInk.integer(session.document.crackMarks.count))
                summaryRow(label: "Pours", value: WellInk.integer(session.document.pourMarks.count))
            } header: {
                Text("Well")
                    .font(WellType.caption)
                    .foregroundStyle(WellPaint.ink)
            }

            Section {
                Button {
                    session.presentCrack()
                } label: {
                    Text("Crack then pour")
                        .frame(maxWidth: .infinity, minHeight: WellMeasure.hit, alignment: .leading)
                        .contentShape(Rectangle())
                }
                .buttonStyle(WellPressStyle())
                .foregroundStyle(WellPaint.ink)
            } header: {
                Text("Rail")
                    .font(WellType.caption)
                    .foregroundStyle(WellPaint.ink)
            } footer: {
                Text("A bottle stays Backbar until Crack seats it. Pour does not empty it.")
                    .font(WellType.caption)
                    .foregroundStyle(WellPaint.ink)
            }

            Section {
                Text("Recipes ship on this device. No remote catalog.")
                    .font(WellType.body)
                    .foregroundStyle(WellPaint.ink)
                    .frame(maxWidth: .infinity, minHeight: WellMeasure.hit, alignment: .leading)
                Link(destination: WellProbe.contactURL) {
                    Text("Contact Speedwell")
                        .frame(maxWidth: .infinity, minHeight: WellMeasure.hit, alignment: .leading)
                        .contentShape(Rectangle())
                }
            } header: {
                Text("Catalog")
                    .font(WellType.caption)
                    .foregroundStyle(WellPaint.ink)
            } footer: {
                Text("https://speedwell-rail.pro/contact-us")
                    .font(WellType.caption)
                    .foregroundStyle(WellPaint.ink)
            }

            Section {
                Button("Replay walkthrough") {
                    session.replayOnboarding()
                }
                .buttonStyle(WellPressStyle())
                .frame(maxWidth: .infinity, minHeight: WellMeasure.hit, alignment: .leading)
                .contentShape(Rectangle())

                Button {
                    confirmReset = true
                } label: {
                    Text("Reset the well")
                        .frame(maxWidth: .infinity, minHeight: WellMeasure.hit)
                        .contentShape(Capsule())
                }
                .buttonStyle(WellDestroyStyle())
                .listRowInsets(EdgeInsets(
                    top: WellMeasure.space(1),
                    leading: WellMeasure.space(2),
                    bottom: WellMeasure.space(1),
                    trailing: WellMeasure.space(2)
                ))
            } header: {
                Text("Well data")
                    .font(WellType.caption)
                    .foregroundStyle(WellPaint.ink)
            }
        }
        .scrollContentBackground(.hidden)
        .background(WellPaint.background.ignoresSafeArea())
        .contentMargins(.bottom, WellMeasure.space(3), for: .scrollContent)
    }

    private func summaryRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(WellType.body)
                .foregroundStyle(WellPaint.ink)
            Spacer()
            Text(value)
                .font(WellType.headline)
                .foregroundStyle(WellPaint.ink)
                .monospacedDigit()
                .lineLimit(1)
        }
        .frame(minHeight: WellMeasure.hit)
        .listRowBackground(WellPaint.surface)
    }
}
