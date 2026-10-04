import Foundation

protocol MedicineRepositoryProtocol {
    func getMedicines(status: MedicineStatus?) async throws -> [MedicineSummaryDTO]
    func getMedicineDetails(id: Int64) async throws -> MedicineDetailDTO
    func createMedicine(request: MedicineCreateUpdateDTO) async throws -> MedicineDetailDTO
    func updateMedicine(id: Int64, request: MedicineCreateUpdateDTO) async throws -> MedicineDetailDTO
    func pauseMedicine(id: Int64) async throws -> MedicineDetailDTO
    func resumeMedicine(id: Int64) async throws -> MedicineDetailDTO
    func deleteMedicine(id: Int64) async throws
}

final class MedicineRepository: MedicineRepositoryProtocol {
    private let client: APIClientProtocol
    
    init(client: APIClientProtocol = APIClient.shared) {
        self.client = client
    }
    
    func getMedicines(status: MedicineStatus? = nil) async throws -> [MedicineSummaryDTO] {
        let endpoint = APIEndpoint.listMedicines(status: status)
        return try await client.request(endpoint)
    }
    
    func getMedicineDetails(id: Int64) async throws -> MedicineDetailDTO {
        let endpoint = APIEndpoint.getMedicineDetails(id: id)
        return try await client.request(endpoint)
    }
    
    func createMedicine(request: MedicineCreateUpdateDTO) async throws -> MedicineDetailDTO {
        let endpoint = try APIEndpoint.createMedicine(request: request)
        return try await client.request(endpoint)
    }
    
    func updateMedicine(id: Int64, request: MedicineCreateUpdateDTO) async throws -> MedicineDetailDTO {
        let endpoint = try APIEndpoint.updateMedicine(id: id, request: request)
        return try await client.request(endpoint)
    }
    
    func pauseMedicine(id: Int64) async throws -> MedicineDetailDTO {
        let endpoint = APIEndpoint.pauseMedicine(id: id)
        return try await client.request(endpoint)
    }
    
    func resumeMedicine(id: Int64) async throws -> MedicineDetailDTO {
        let endpoint = APIEndpoint.resumeMedicine(id: id)
        return try await client.request(endpoint)
    }
    
    func deleteMedicine(id: Int64) async throws {
        let endpoint = APIEndpoint.deleteMedicine(id: id)
        let _: String? = try? await client.request(endpoint)
    }
}
