import SwiftUI

/// Root well. Surprise never leaves. Pour fuses here. Bar, Discover, Favorites, Settings arrive as sheets.
struct WellChrome: View {
    @Environment(WellBooth.self) private var session
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        @Bindable var session = session
        SurpriseView()
            .sheet(item: $session.presentedSheet) { sheet in
                NavigationStack {
                    switch sheet {
                    case .bar:
                        BarView()
                    case .discover:
                        DiscoverView()
                    case .favorites:
                        FavoritesView()
                    case .settings:
                        SettingsView()
                    }
                }
                .presentationDetents([.large])
                .presentationCornerRadius(WellMeasure.card)
                .presentationBackground(WellPaint.surface)
            }
            .sheet(isPresented: $session.crackPresented) {
                NavigationStack {
                    CrackStage()
                }
                .presentationDetents([.large])
                .presentationCornerRadius(WellMeasure.card)
                .presentationBackground(WellPaint.surface)
            }
            .overlay {
                if session.commitFlash {
                    Image("spw_SuccessMark")
                        .resizable()
                        .scaledToFit()
                        .frame(width: WellMeasure.space(12), height: WellMeasure.space(12))
                        .accessibilityHidden(true)
                        .allowsHitTesting(false)
                        .transition(reduceMotion ? .opacity : .scale.combined(with: .opacity))
                }
            }
            .animation(WellPulse.ease(), value: session.commitFlash)
            .task { session.noteChromeVisible() }
    }
}
