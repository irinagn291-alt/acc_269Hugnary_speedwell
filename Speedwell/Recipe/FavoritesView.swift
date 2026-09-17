import SwiftUI

/// Pinned recipes. Recipe copy is read here as a row, never a pushed detail.
struct FavoritesView: View {
    @Environment(WellBooth.self) private var session
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Group {
            if let fault = session.favoritesFault, session.favorites.isEmpty {
                WellFaultCutout(
                    headline: "Pins failed.",
                    line: fault,
                    retry: { session.retryFavorites() }
                )
            } else if session.favorites.isEmpty {
                WellCutout(
                    artName: "spw_EmptyList",
                    headline: "No pins yet.",
                    line: "Pin a recipe on the well if you will mix it again.",
                    verb: "Back to the well",
                    action: { dismiss() }
                )
            } else {
                populated
            }
        }
        .background(WellPaint.background.ignoresSafeArea())
        .navigationTitle("Favorites")
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
            if let fault = session.favoritesFault {
                Section {
                    HStack {
                        Text(fault)
                            .font(WellType.body)
                            .foregroundStyle(WellPaint.ink)
                        Spacer()
                        Button("Retry") { session.retryFavorites() }
                            .buttonStyle(WellChipStyle(filled: true))
                    }
                    .listRowBackground(WellPaint.surface)
                }
            }

            Section {
                ForEach(session.favorites) { recipe in
                    HStack(alignment: .top, spacing: WellMeasure.space(1)) {
                        Image("spw_CoupeGlass")
                            .resizable()
                            .scaledToFit()
                            .frame(width: WellMeasure.space(5), height: WellMeasure.space(5))
                            .accessibilityHidden(true)
                        VStack(alignment: .leading, spacing: 0) {
                            Text(recipe.name)
                                .font(WellType.headline)
                                .foregroundStyle(WellPaint.ink)
                                .lineLimit(1)
                            Text(recipe.method)
                                .font(WellType.body)
                                .foregroundStyle(WellPaint.ink)
                                .lineLimit(2)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        Button {
                            Task { await session.unpin(recipe.id) }
                        } label: {
                            Image(systemName: "bookmark.fill")
                                .frame(minWidth: WellMeasure.hit, minHeight: WellMeasure.hit)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(WellPressStyle())
                        .foregroundStyle(WellPaint.ink)
                        .accessibilityLabel("Unpin \(recipe.name)")
                    }
                    .frame(minHeight: WellMeasure.hit)
                    .listRowBackground(WellPaint.surface)
                }
            } header: {
                Text("Pinned")
                    .font(WellType.caption)
                    .foregroundStyle(WellPaint.ink)
            }
        }
        .scrollContentBackground(.hidden)
        .background(WellPaint.background)
        .contentMargins(.bottom, WellMeasure.space(3), for: .scrollContent)
    }
}
