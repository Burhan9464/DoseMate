import Foundation

protocol DashboardRepositoryProtocol {
    func getDashboard() async throws -> DashboardDTO
}

final class DashboardRepository: DashboardRepositoryProtocol {
    private let client: APIClientProtocol
    
    init(client: APIClientProtocol = APIClient.shared) {
        self.client = client
    }
    
    func getDashboard() async throws -> DashboardDTO {
        let endpoint = APIEndpoint.getDashboard()
        return try await client.request(endpoint)
    }
}
