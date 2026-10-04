import SwiftUI

@MainActor
final class MedicineListViewModel: ObservableObject {
    @Published var medicines: [MedicineSummaryDTO] = []
    @Published var searchText: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    private let medicineRepository: MedicineRepositoryProtocol
    
    init(medicineRepository: MedicineRepositoryProtocol = MedicineRepository()) {
        self.medicineRepository = medicineRepository
    }
    
    var activeMedicines: [MedicineSummaryDTO] {
        filteredMedicines.filter { $0.status == .active }
    }
    
    var pausedMedicines: [MedicineSummaryDTO] {
        filteredMedicines.filter { $0.status == .paused }
    }
    
    private var filteredMedicines: [MedicineSummaryDTO] {
        if searchText.trimmingCharacters(in: .whitespaces).isEmpty {
            return medicines
        }
        return medicines.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.formattedDosage.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    func loadMedicines() async {
        isLoading = true
        errorMessage = nil
        do {
            self.medicines = try await medicineRepository.getMedicines(status: nil)
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
