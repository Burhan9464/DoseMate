import Foundation

protocol DoseRepositoryProtocol {
    func getTodayDoses() async throws -> [DoseRecordDTO]
    func markTaken(id: Int64) async throws -> DoseTakenResponseDTO
    func markSkipped(id: Int64) async throws -> DoseRecordDTO
    func undoSkip(id: Int64) async throws -> DoseRecordDTO
    func getHistory(
        status: String?,
        search: String?,
        startDate: String?,
        endDate: String?,
        page: Int,
        size: Int
    ) async throws -> [DoseRecordDTO]
}

final class DoseRepository: DoseRepositoryProtocol {
    private let client: APIClientProtocol
    
    init(client: APIClientProtocol = APIClient.shared) {
        self.client = client
    }
    
    func getTodayDoses() async throws -> [DoseRecordDTO] {
        let endpoint = APIEndpoint.getTodayDoses()
        return try await client.request(endpoint)
    }
    
    func markTaken(id: Int64) async throws -> DoseTakenResponseDTO {
        let endpoint = APIEndpoint.markDoseTaken(id: id)
        return try await client.request(endpoint)
    }
    
    func markSkipped(id: Int64) async throws -> DoseRecordDTO {
        let endpoint = APIEndpoint.markDoseSkipped(id: id)
        return try await client.request(endpoint)
    }
    
    func undoSkip(id: Int64) async throws -> DoseRecordDTO {
        let endpoint = APIEndpoint.undoSkipDose(id: id)
        return try await client.request(endpoint)
    }
    
    func getHistory(
        status: String? = nil,
        search: String? = nil,
        startDate: String? = nil,
        endDate: String? = nil,
        page: Int = 0,
        size: Int = 50
    ) async throws -> [DoseRecordDTO] {
        let endpoint = APIEndpoint.getHistory(
            status: status,
            search: search,
            startDate: startDate,
            endDate: endDate,
            page: page,
            size: size
        )
        return try await client.request(endpoint)
    }
}
