import Foundation

protocol AuthRepositoryProtocol {
    func login(request: LoginRequest) async throws -> AuthResponseData
    func register(request: RegisterRequest) async throws -> AuthResponseData
    func logout() async throws
}

final class AuthRepository: AuthRepositoryProtocol {
    private let client: APIClientProtocol
    
    init(client: APIClientProtocol = APIClient.shared) {
        self.client = client
    }
    
    func login(request: LoginRequest) async throws -> AuthResponseData {
        let endpoint = try APIEndpoint.login(request: request)
        return try await client.request(endpoint)
    }
    
    func register(request: RegisterRequest) async throws -> AuthResponseData {
        let endpoint = try APIEndpoint.register(request: request)
        return try await client.request(endpoint)
    }
    
    func logout() async throws {
        let endpoint = APIEndpoint.logout()
        let _: String? = try? await client.request(endpoint)
    }
}
