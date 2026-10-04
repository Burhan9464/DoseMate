import Foundation

protocol UserRepositoryProtocol {
    func getProfile() async throws -> UserDTO
    func updateProfile(request: UserUpdateDTO) async throws -> UserDTO
    func updateFlags(flags: UserFlagsDTO) async throws -> UserDTO
}

final class UserRepository: UserRepositoryProtocol {
    private let client: APIClientProtocol
    
    init(client: APIClientProtocol = APIClient.shared) {
        self.client = client
    }
    
    func getProfile() async throws -> UserDTO {
        let endpoint = APIEndpoint.getProfile()
        return try await client.request(endpoint)
    }
    
    func updateProfile(request: UserUpdateDTO) async throws -> UserDTO {
        let endpoint = try APIEndpoint.updateProfile(request: request)
        return try await client.request(endpoint)
    }
    
    func updateFlags(flags: UserFlagsDTO) async throws -> UserDTO {
        let endpoint = try APIEndpoint.updateFlags(flags: flags)
        return try await client.request(endpoint)
    }
}
