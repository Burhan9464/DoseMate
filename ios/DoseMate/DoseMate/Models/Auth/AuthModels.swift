import Foundation

struct LoginRequest: Codable {
    let email: String
    let password: String
}

struct RegisterRequest: Codable {
    let fullName: String
    let email: String
    let password: String
    let dateOfBirth: String?
    let gender: String?
    let country: String?
    let timezone: String?
}

struct AuthResponseData: Codable {
    let token: String
    let tokenType: String
    let expiresIn: Int64
    let user: UserDTO
}
