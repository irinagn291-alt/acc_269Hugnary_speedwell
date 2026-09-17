import SwiftUI

/// Tonight's well. Onboarding, then Surprise. ReviewScreen is read after onboarding.
struct ContentView: View {
    @State private var session = WellBooth.shared
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        Group {
            if let fault = session.bootFault, !session.isReady {
                WellFaultCutout(
                    headline: "Well did not open.",
                    line: fault,
                    retry: {
                        Task { await session.retryBoot() }
                    }
                )
            } else if !session.isReady {
                WellPaint.background
                    .ignoresSafeArea()
                    .overlay {
                        Image("spw_Splash")
                            .resizable()
                            .scaledToFill()
                            .ignoresSafeArea()
                            .accessibilityHidden(true)
                    }
            } else if session.showOnboarding {
                OnboardingCover()
            } else {
                WellChrome()
            }
        }
        .environment(session)
        .background(WellPaint.background.ignoresSafeArea())
        .tint(WellPaint.accent)
        .preferredColorScheme(.light)
        .task { await session.boot() }
        .onOpenURL { session.open(url: $0) }
        .onChange(of: scenePhase) { _, phase in
            Task { await session.handle(phase: phase) }
        }
    }
}

#Preview {
    ContentView()
        .environment(WellBooth.shared)
}
