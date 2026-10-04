import Foundation

protocol InventoryRepositoryProtocol {
    func getInventory(medicineId: Int64) async throws -> InventoryDTO
    func updateInventory(medicineId: Int64, quantity: Int) async throws -> InventoryDTO
    func refillInventory(medicineId: Int64, amount: Int) async throws -> InventoryDTO
}

final class InventoryRepository: InventoryRepositoryProtocol {
    private let client: APIClientProtocol
    
    init(client: APIClientProtocol = APIClient.shared) {
        self.client = client
    }
    
    func getInventory(medicineId: Int64) async throws -> InventoryDTO {
        let endpoint = APIEndpoint.getInventory(medicineId: medicineId)
        return try await client.request(endpoint)
    }
    
    func updateInventory(medicineId: Int64, quantity: Int) async throws -> InventoryDTO {
        let endpoint = try APIEndpoint.updateInventory(medicineId: medicineId, quantity: quantity)
        return try await client.request(endpoint)
    }
    
    func refillInventory(medicineId: Int64, amount: Int) async throws -> InventoryDTO {
        let endpoint = try APIEndpoint.refillInventory(medicineId: medicineId, amount: amount)
        return try await client.request(endpoint)
    }
}
