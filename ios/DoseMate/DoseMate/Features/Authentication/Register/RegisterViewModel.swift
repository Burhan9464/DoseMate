import SwiftUI

enum RegisterStep: Int, CaseIterable {
    case account = 1
    case personal = 2
}

@MainActor
final class RegisterViewModel: ObservableObject {
    @Published var currentStep: RegisterStep = .account
    
    // Step 1: Account
    @Published var fullName: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    
    // Step 2: Personal
    @Published var dateOfBirth: Date = Calendar.current.date(byAdding: .year, value: -25, to: Date()) ?? Date()
    @Published var gender: String = "PREFER_NOT_TO_SAY"
    @Published var selectedCountry: String = "United States"
    @Published var timezone: String = TimeZone.current.identifier
    
    // Validation Errors
    @Published var fullNameError: String? = nil
    @Published var emailError: String? = nil
    @Published var passwordError: String? = nil
    @Published var confirmPasswordError: String? = nil
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var isRegistrationSuccessful: Bool = false
    @Published var registeredAuthData: AuthResponseData? = nil
    
    private let authRepository: AuthRepositoryProtocol
    
    init(authRepository: AuthRepositoryProtocol = AuthRepository()) {
        self.authRepository = authRepository
    }
    
    func validateStep1() -> Bool {
        var isValid = true
        fullNameError = nil
        emailError = nil
        passwordError = nil
        confirmPasswordError = nil
        errorMessage = nil
        
        let trimmedName = fullName.trimmingCharacters(in: .whitespaces)
        if trimmedName.isEmpty {
            fullNameError = "Full name is required."
            isValid = false
        }
        
        let trimmedEmail = email.trimmingCharacters(in: .whitespaces)
        if trimmedEmail.isEmpty {
            emailError = "Email is required."
            isValid = false
        } else if !trimmedEmail.contains("@") || !trimmedEmail.contains(".") {
            emailError = "Please enter a valid email address."
            isValid = false
        }
        
        if password.isEmpty {
            passwordError = "Password is required."
            isValid = false
        } else if password.count < 8 {
            passwordError = "Password must be at least 8 characters."
            isValid = false
        }
        
        if confirmPassword != password {
            confirmPasswordError = "Passwords do not match."
            isValid = false
        }
        
        return isValid
    }
    
    func proceedToStep2() {
        if validateStep1() {
            withAnimation(.easeInOut(duration: 0.25)) {
                currentStep = .personal
            }
        }
    }
    
    func backToStep1() {
        withAnimation(.easeInOut(duration: 0.25)) {
            currentStep = .account
        }
    }
    
    func register() async -> Bool {
        isLoading = true
        errorMessage = nil
        
        do {
            let request = RegisterRequest(
                fullName: fullName.trimmingCharacters(in: .whitespaces),
                email: email.trimmingCharacters(in: .whitespaces).lowercased(),
                password: password,
                dateOfBirth: dateOfBirth.toAPIDateString,
                gender: gender,
                country: selectedCountry,
                timezone: timezone
            )
            
            let response = try await authRepository.register(request: request)
            registeredAuthData = response
            isRegistrationSuccessful = true
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
