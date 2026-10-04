import SwiftUI

@MainActor
final class SplashViewModel: ObservableObject {
    @Published var isAnimating: Bool = false
    
    func startInitialFlow(appState: AppState) async {
        isAnimating = true
        // Brief branded animation (0.6s) alongside session restoration
        async let sessionRestore: () = appState.restoreSession()
        async let animationDelay: () = Task.sleep(nanoseconds: 600_000_000)
        _ = await (sessionRestore, animationDelay)
    }
}
