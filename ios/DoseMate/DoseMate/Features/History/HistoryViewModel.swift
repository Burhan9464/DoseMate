import SwiftUI

@MainActor
final class HistoryViewModel: ObservableObject {
    @Published var historyRecords: [DoseRecordDTO] = []
    @Published var selectedFilter: String = "ALL" // "ALL", "TAKEN", "SKIPPED", "MISSED"
    @Published var searchText: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    let filterOptions = ["ALL", "TAKEN", "SKIPPED", "MISSED"]
    
    private let doseRepository: DoseRepositoryProtocol
    
    init(doseRepository: DoseRepositoryProtocol = DoseRepository()) {
        self.doseRepository = doseRepository
    }
    
    /// Groups history items by relative date header ("Today", "Yesterday", "Monday, Oct 5").
    var groupedHistory: [DoseHistoryGroup] {
        let calendar = Calendar.current
        var groups: [String: [DoseRecordDTO]] = [:]
        var order: [String] = []
        
        for record in historyRecords {
            let header: String
            if let date = record.scheduledDate {
                header = date.relativeDayHeader
            } else {
                header = "Past Doses"
            }
            
            if groups[header] == nil {
                groups[header] = []
                order.append(header)
            }
            groups[header]?.append(record)
        }
        
        return order.map { header in
            DoseHistoryGroup(dateHeader: header, doses: groups[header] ?? [])
        }
    }
    
    func loadHistory() async {
        isLoading = true
        errorMessage = nil
        do {
            let records = try await doseRepository.getHistory(
                status: selectedFilter == "ALL" ? nil : selectedFilter,
                search: searchText.trimmingCharacters(in: .whitespaces).isEmpty ? nil : searchText,
                startDate: nil,
                endDate: nil,
                page: 0,
                size: 50
            )
            self.historyRecords = records
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
