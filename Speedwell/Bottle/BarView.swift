import SwiftUI

/// Owned bottles. Adding writes Backbar. Crack seats. Recork lifts. Stock List, not a second well hero.
struct BarView: View {
    @Environment(WellBooth.self) private var session
    @Environment(\.dismiss) private var dismiss
    @State private var adding = false

    var body: some View {
        Group {
            if let fault = session.barFault, session.barEmpty, !adding {
                WellFaultCutout(
                    headline: "Bar failed.",
                    line: fault,
                    retry: { session.retryBar() }
                )
            } else if session.barEmpty, !adding {
                WellCutout(
                    artName: "spw_EmptyList",
                    headline: "The bar is empty.",
                    line: "Add a bottle, then pour.",
                    verb: "Add a bottle",
                    action: { adding = true }
                )
            } else {
                BarStockList()
            }
        }
        .background(WellPaint.background.ignoresSafeArea())
        .navigationTitle("Bar")
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
}

private struct BarStockList: View {
    @Environment(WellBooth.self) private var session
    @FocusState private var nameFocused: Bool

    var body: some View {
        @Bindable var session = session
        List {
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

            Section {
                TextField("Bottle name", text: $session.addDraftName)
                    .font(WellType.body)
                    .foregroundStyle(WellPaint.ink)
                    .frame(minHeight: WellMeasure.hit)
                    .submitLabel(.done)
                    .focused($nameFocused)
                Picker("Kind", selection: $session.addDraftKind) {
                    ForEach(session.kindChoices, id: \.self) { kind in
                        Text(WellInk.kind(kind)).tag(kind)
                    }
                }
                .frame(minHeight: WellMeasure.hit)
                Button("Add bottle") {
                    nameFocused = false
                    Task { await session.addBottle() }
                }
                .buttonStyle(WellFillStyle())
                .disabled(session.addDraftName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || session.verbBusy)
                .listRowInsets(EdgeInsets(
                    top: WellMeasure.space(1),
                    leading: WellMeasure.space(2),
                    bottom: WellMeasure.space(1),
                    trailing: WellMeasure.space(2)
                ))
                .listRowBackground(Color.clear)
            } header: {
                Text("Own")
                    .font(WellType.caption)
                    .foregroundStyle(WellPaint.ink)
            } footer: {
                Text("Add writes Backbar. Crack seats it on the rail.")
                    .font(WellType.caption)
                    .foregroundStyle(WellPaint.ink)
            }

            if !session.seated.isEmpty {
                Section {
                    ForEach(session.seated) { bottle in
                        BarBottleRow(bottle: bottle, verb: "Recork", filled: false) {
                            Task { await session.recork(bottle.id) }
                        }
                    }
                } header: {
                    Text("Seated")
                        .font(WellType.caption)
                        .foregroundStyle(WellPaint.ink)
                }
            }

            if !session.backbar.isEmpty {
                Section {
                    ForEach(session.backbar) { bottle in
                        BarBottleRow(bottle: bottle, verb: "Crack", filled: true) {
                            Task { await session.crack(bottle.id) }
                        }
                    }
                } header: {
                    Text("Backbar")
                        .font(WellType.caption)
                        .foregroundStyle(WellPaint.ink)
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(WellPaint.background)
        .scrollDismissesKeyboard(.interactively)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    nameFocused = false
                }
                .font(WellType.headline)
                .foregroundStyle(WellPaint.ink)
                .frame(minHeight: WellMeasure.hit)
            }
        }
        .contentMargins(.bottom, WellMeasure.space(3), for: .scrollContent)
    }
}

private struct BarBottleRow: View {
    @Environment(WellBooth.self) private var session
    var bottle: Bottle
    var verb: String
    var filled: Bool
    var action: () -> Void

    var body: some View {
        HStack(spacing: WellMeasure.space(1)) {
            Image(bottle.seat == .seated ? "spw_RailBottle" : "spw_SealedCork")
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
            Button(verb, action: action)
                .buttonStyle(WellChipStyle(filled: filled))
                .disabled(session.verbBusy)
                .accessibilityLabel("\(verb) \(bottle.name)")
        }
        .frame(minHeight: WellMeasure.hit)
        .listRowBackground(WellPaint.surface)
    }
}
