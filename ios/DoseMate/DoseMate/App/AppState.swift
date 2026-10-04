import SwiftUI
import Combine

/// Central source of truth for user session, authentication, and guide progression.
final class AppState: ObservableObject {
    static let shared = AppState()
    
    @Published var isAuthenticated: Bool = false
    @Published var currentUser: UserDTO? = nil
    @Published var isOnboardingCompleted: Bool = false
    @Published var isGuideCompleted: Bool = false
    @Published var shouldShowGuide: Bool = false
    @Published var isLoadingSession: Bool = true
    
    private let userRepository: UserRepositoryProtocol
    private let authRepository: AuthRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(
        userRepository: UserRepositoryProtocol = UserRepository(),
        authRepository: AuthRepositoryProtocol = AuthRepository()
    ) {
        self.userRepository = userRepository
        self.authRepository = authRepository
        
        self.isOnboardingCompleted = UserDefaults.standard.bool(forKey: AppConstants.StorageKeys.onboardingCompletedKey)
        self.isGuideCompleted = UserDefaults.standard.bool(forKey: AppConstants.StorageKeys.guideCompletedKey)
        
        setupSessionObserver()
    }
    
    private func setupSessionObserver() {
        NotificationCenter.default.publisher(for: .userSessionExpired)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.handleSessionExpired()
            }
            .store(in: &cancellables)
    }
    
    /// Checks Keychain for existing JWT and attempts to fetch current user profile.
    @MainActor
    func restoreSession() async {
        isLoadingSession = true
        guard KeychainService.shared.hasToken() else {
            isAuthenticated = false
            currentUser = nil
            isLoadingSession = false
            return
        }
        
        do {
            let profile = try await userRepository.getProfile()
            self.currentUser = profile
            self.isAuthenticated = true
            self.isOnboardingCompleted = profile.onboardingCompleted || self.isOnboardingCompleted
            self.isGuideCompleted = profile.guideCompleted || self.isGuideCompleted
            
            // If new user registered but hasn't completed guide, prompt guide
            if !profile.guideCompleted && !self.isGuideCompleted {
                self.shouldShowGuide = true
            }
        } catch {
            // Token invalid or network failure
            print("[AppState] Session restoration failed: \(error.localizedDescription)")
            KeychainService.shared.deleteToken()
            self.isAuthenticated = false
            self.currentUser = nil
        }
        isLoadingSession = false
    }
    
    @MainActor
    func setAuthenticated(token: String, user: UserDTO, isNewRegistration: Bool = false) {
        _ = KeychainService.shared.saveToken(token)
        self.currentUser = user
        self.isAuthenticated = true
        self.isOnboardingCompleted = true
        UserDefaults.standard.set(true, forKey: AppConstants.StorageKeys.onboardingCompletedKey)
        
        if isNewRegistration || (!user.guideCompleted && !isGuideCompleted) {
            self.shouldShowGuide = true
        }
    }
    
    @MainActor
    func completeOnboarding() {
        isOnboardingCompleted = true
        UserDefaults.standard.set(true, forKey: AppConstants.StorageKeys.onboardingCompletedKey)
        
        if isAuthenticated {
            Task {
                _ = try? await userRepository.updateFlags(flags: UserFlagsDTO(onboardingCompleted: true, guideCompleted: nil))
            }
        }
    }
    
    @MainActor
    func completeGuide() {
        isGuideCompleted = true
        shouldShowGuide = false
        UserDefaults.standard.set(true, forKey: AppConstants.StorageKeys.guideCompletedKey)
        
        if isAuthenticated {
            Task {
                _ = try? await userRepository.updateFlags(flags: UserFlagsDTO(onboardingCompleted: nil, guideCompleted: true))
            }
        }
    }
    
    @MainActor
    func replayGuide() {
        shouldShowGuide = true
    }
    
    @MainActor
    func logout() {
        Task {
            try? await authRepository.logout()
        }
        _ = KeychainService.shared.deleteToken()
        NotificationService.shared.cancelAll()
        self.isAuthenticated = false
        self.currentUser = nil
        self.shouldShowGuide = false
    }
    
    @MainActor
    private func handleSessionExpired() {
        _ = KeychainService.shared.deleteToken()
        self.isAuthenticated = false
        self.currentUser = nil
    }
}
