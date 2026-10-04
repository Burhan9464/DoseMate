import SwiftUI

@MainActor
final class LoginViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    @Published var emailError: String? = nil
    @Published var passwordError: String? = nil
    
    private let authRepository: AuthRepositoryProtocol
    
    init(authRepository: AuthRepositoryProtocol = AuthRepository()) {
        self.authRepository = authRepository
    }
    
    func validate() -> Bool {
        var isValid = true
        emailError = nil
        passwordError = nil
        errorMessage = nil
        
        let trimmedEmail = email.trimmingCharacters(in: .whitespaces)
        if trimmedEmail.isEmpty {
            emailError = "Email address is required."
            isValid = false
        } else if !trimmedEmail.contains("@") || !trimmedEmail.contains(".") {
            emailError = "Please enter a valid email address."
            isValid = false
        }
        
        if password.isEmpty {
            passwordError = "Password is required."
            isValid = false
        }
        
        return isValid
    }
    
    func login(appState: AppState) async -> Bool {
        guard validate() else { return false }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let request = LoginRequest(
                email: email.trimmingCharacters(in: .whitespaces).lowercased(),
                password: password
            )
            let response = try await authRepository.login(request: request)
            appState.setAuthenticated(token: response.token, user: response.user)
            isLoading = false
            return true
        } catch let apiError as APIError {
            isLoading = false
            errorMessage = apiError.errorDescription
            return false
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
            return false
        }
    }
}
