import SwiftUI

@MainActor
final class EditProfileViewModel: ObservableObject {
    @Published var fullName: String
    @Published var dateOfBirth: Date
    @Published var gender: String
    @Published var selectedCountry: String
    @Published var timezone: String
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    private let userRepository: UserRepositoryProtocol
    
    init(user: UserDTO?, userRepository: UserRepositoryProtocol = UserRepository()) {
        self.userRepository = userRepository
        self.fullName = user?.fullName ?? ""
        self.dateOfBirth = user?.dateOfBirth?.toDateFromAPIDate ?? Calendar.current.date(byAdding: .year, value: -25, to: Date()) ?? Date()
        self.gender = user?.gender ?? "PREFER_NOT_TO_SAY"
        self.selectedCountry = user?.country ?? "United States"
        self.timezone = user?.timezone ?? TimeZone.current.identifier
    }
    
    func saveProfile() async -> Bool {
        let trimmedName = fullName.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else {
            errorMessage = "Full name cannot be empty."
            return false
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let request = UserUpdateDTO(
                fullName: trimmedName,
                dateOfBirth: dateOfBirth.toAPIDateString,
                gender: gender,
                country: selectedCountry,
                timezone: timezone
            )
            _ = try await userRepository.updateProfile(request: request)
            HapticService.shared.success()
            isLoading = false
            return true
        } catch let apiError as APIError {
            isLoading = false
            self.errorMessage = apiError.errorDescription
            return false
        } catch {
            isLoading = false
            self.errorMessage = error.localizedDescription
            return false
        }
    }
}
