import Foundation

/// User profile representation matching the backend UserResponseDTO.
struct UserDTO: Codable, Identifiable, Equatable {
    let id: Int64
    var fullName: String
    var email: String
    var dateOfBirth: String?
    var gender: String?
    var country: String?
    var timezone: String?
    var onboardingCompleted: Bool
    var guideCompleted: Bool
}

/// Request body for updating user profile info.
struct UserUpdateDTO: Codable {
    let fullName: String
    let dateOfBirth: String?
    let gender: String?
    let country: String?
    let timezone: String?
}

/// Request body for updating app walkthrough and onboarding flags.
struct UserFlagsDTO: Codable {
    let onboardingCompleted: Bool?
    let guideCompleted: Bool?
}
