import SwiftUI

/// Makeable recipes versus missing seated bottles. Counts makeable recipes and CrackMarks, not a shopping list.
struct DiscoverView: View {
    @Environment(WellBooth.self) private var session
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Group {
            if let fault = session.discoverFault, session.sights.isEmpty {
                WellFaultCutout(
                    headline: "Book failed.",
                    line: fault,
                    retry: { session.retryDiscover() }
                )
            } else if session.sights.isEmpty {
                WellCutout(
                    artName: "spw_EmptyList",
                    headline: "The book is empty.",
                    line: "Recipes ship with this app.",
                    verb: "Back to the well",
                    action: { dismiss() }
                )
            } else {
                populated
            }
        }
        .background(WellPaint.background.ignoresSafeArea())
        .navigationTitle("Discover")
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

    private var readySights: [RecipeSight] {
        session.sights.filter(\.isMakeable)
    }

    private var missingSights: [RecipeSight] {
        session.sights.filter { !$0.isMakeable }
    }

    private var populated: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: WellMeasure.space(1)) {
                    Text(WellInk.integer(session.makeable.count))
                        .font(WellType.display)
                        .foregroundStyle(WellPaint.accent)
                        .monospacedDigit()
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                    Text("makeable on this rail")
                        .font(WellType.body)
                        .foregroundStyle(WellPaint.ink)
                    HStack(spacing: WellMeasure.space(2)) {
                        Text("Cracks")
                        Text(WellInk.integer(session.document.crackMarks.count))
                            .monospacedDigit()
                        Text("Pours")
                        Text(WellInk.integer(session.document.pourMarks.count))
                            .monospacedDigit()
                    }
                    .font(WellType.caption)
                    .foregroundStyle(WellPaint.ink)
                    .monospacedDigit()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, WellMeasure.space(1))
                .listRowBackground(WellPaint.surface)
                .accessibilityElement(children: .combine)
                .accessibilityLabel(
                    "\(WellInk.integer(session.makeable.count)) makeable. \(WellInk.integer(session.document.crackMarks.count)) cracks."
                )
            }

            if let fault = session.discoverFault {
                Section {
                    HStack {
                        Text(fault)
                            .font(WellType.body)
                            .foregroundStyle(WellPaint.ink)
                        Spacer()
                        Button("Retry") { session.retryDiscover() }
                            .buttonStyle(WellChipStyle(filled: true))
                    }
                    .listRowBackground(WellPaint.surface)
                }
            }

            if !readySights.isEmpty {
                Section {
                    ForEach(readySights) { sight in
                        recipeRow(sight)
                    }
                } header: {
                    Text("Makeable")
                        .font(WellType.caption)
                        .foregroundStyle(WellPaint.ink)
                }
            }

            if !missingSights.isEmpty {
                Section {
                    ForEach(missingSights) { sight in
                        recipeRow(sight)
                    }
                } header: {
                    Text("Missing a seated bottle")
                        .font(WellType.caption)
                        .foregroundStyle(WellPaint.ink)
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(WellPaint.background)
        .contentMargins(.bottom, WellMeasure.space(3), for: .scrollContent)
    }

    private func recipeRow(_ sight: RecipeSight) -> some View {
        VStack(alignment: .leading, spacing: WellMeasure.space(1)) {
            HStack {
                Text(sight.recipe.name)
                    .font(WellType.headline)
                    .foregroundStyle(WellPaint.ink)
                    .lineLimit(1)
                Spacer(minLength: 0)
                Text(sight.isMakeable ? "Makeable" : "Missing")
                    .font(WellType.caption)
                    .foregroundStyle(WellPaint.ink)
                    .padding(.horizontal, WellMeasure.space(1))
                    .padding(.vertical, WellMeasure.space(1))
                    .wellChip()
            }
            if !sight.missingKinds.isEmpty {
                Text(sight.missingKinds.map(WellInk.kind).joined(separator: ", "))
                    .font(WellType.caption)
                    .foregroundStyle(WellPaint.ink)
                    .lineLimit(2)
            }
            if let sealed = sight.missingKinds.compactMap({ session.backbarBottle(kind: $0) }).first {
                Button("Crack \(sealed.name)") {
                    Task { await session.crack(sealed.id) }
                }
                .buttonStyle(WellChipStyle(filled: true))
                .disabled(session.verbBusy)
            }
        }
        .padding(.vertical, WellMeasure.space(1))
        .listRowBackground(WellPaint.surface)
    }
}
