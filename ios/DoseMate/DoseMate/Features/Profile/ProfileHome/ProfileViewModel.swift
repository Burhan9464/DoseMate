import SwiftUI

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published var user: UserDTO? = nil
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    private let userRepository: UserRepositoryProtocol
    
    init(userRepository: UserRepositoryProtocol = UserRepository()) {
        self.userRepository = userRepository
    }
    
    func loadProfile() async {
        isLoading = true
        errorMessage = nil
        do {
            let profile = try await userRepository.getProfile()
            self.user = profile
            self.isLoading = false
        } catch let apiError as APIError {
            self.isLoading = false
            self.errorMessage = apiError.errorDescription
        } catch {
            self.isLoading = false
            self.errorMessage = error.localizedDescription
        }
    }
}
