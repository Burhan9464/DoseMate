import SwiftUI

@main
struct DoseMateApp: App {
    @StateObject private var appState = AppState.shared
    @StateObject private var router = AppRouter()
    @State private var isShowingRegister: Bool = false
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if appState.isLoadingSession {
                    SplashView()
                        .transition(.opacity)
                } else if !appState.isOnboardingCompleted {
                    OnboardingView(onFinish: {
                        appState.completeOnboarding()
                    })
                    .transition(.asymmetric(insertion: .opacity, removal: .move(edge: .leading)))
                } else if !appState.isAuthenticated {
                    NavigationStack {
                        LoginView(onNavigateToRegister: {
                            isShowingRegister = true
                        })
                        .navigationDestination(isPresented: $isShowingRegister) {
                            RegisterView()
                        }
                    }
                    .transition(.opacity)
                } else {
                    MainTabView()
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.3), value: appState.isLoadingSession)
            .animation(.easeInOut(duration: 0.3), value: appState.isOnboardingCompleted)
            .animation(.easeInOut(duration: 0.3), value: appState.isAuthenticated)
            .environmentObject(appState)
            .environmentObject(router)
            .onChange(of: scenePhase) { phase in
                if phase == .active {
                    NotificationService.shared.checkAuthorizationStatus()
                }
            }
        }
    }
}
