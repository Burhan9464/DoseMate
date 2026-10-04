import SwiftUI

@MainActor
final class MedicineDetailsViewModel: ObservableObject {
    let medicineId: Int64
    
    @Published var medicine: MedicineDetailDTO? = nil
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var isActionInProgress: Bool = false
    
    // Modal Sheets / Dialogs
    @Published var showRefillSheet: Bool = false
    @Published var refillAmountText: String = "30"
    
    @Published var showCorrectionSheet: Bool = false
    @Published var correctedQuantityText: String = ""
    
    @Published var showDeleteConfirmation: Bool = false
    @Published var isDeleted: Bool = false
    
    private let medicineRepository: MedicineRepositoryProtocol
    private let inventoryRepository: InventoryRepositoryProtocol
    
    init(
        medicineId: Int64,
        medicineRepository: MedicineRepositoryProtocol = MedicineRepository(),
        inventoryRepository: InventoryRepositoryProtocol = InventoryRepository()
    ) {
        self.medicineId = medicineId
        self.medicineRepository = medicineRepository
        self.inventoryRepository = inventoryRepository
    }
    
    func loadDetails() async {
        isLoading = true
        errorMessage = nil
        do {
            let details = try await medicineRepository.getMedicineDetails(id: medicineId)
            self.medicine = details
            if let qty = details.inventory?.quantity {
                self.correctedQuantityText = "\(qty)"
            }
            self.isLoading = false
        } catch let apiError as APIError {
            self.isLoading = false
            self.errorMessage = apiError.errorDescription
        } catch {
            self.isLoading = false
            self.errorMessage = error.localizedDescription
        }
    }
    
    func togglePauseResume() async {
        guard let medicine = medicine, !isActionInProgress else { return }
        isActionInProgress = true
        errorMessage = nil
        
        do {
            if medicine.status == .active {
                let updated = try await medicineRepository.pauseMedicine(id: medicineId)
                self.medicine = updated
                NotificationService.shared.cancelReminders(for: medicineId)
                HapticService.shared.warning()
            } else {
                let updated = try await medicineRepository.resumeMedicine(id: medicineId)
                self.medicine = updated
                if let schedule = updated.schedule {
                    NotificationService.shared.scheduleReminders(
                        medicineId: updated.id,
                        medicineName: updated.name,
                        dosage: updated.formattedDosage,
                        schedule: schedule
                    )
                }
                HapticService.shared.success()
            }
            isActionInProgress = false
        } catch let apiError as APIError {
            isActionInProgress = false
            self.errorMessage = apiError.errorDescription
        } catch {
            isActionInProgress = false
            self.errorMessage = error.localizedDescription
        }
    }
    
    func refillInventory() async {
        guard let amount = Int(refillAmountText), amount > 0 else { return }
        isActionInProgress = true
        errorMessage = nil
        
        do {
            let updatedInventory = try await inventoryRepository.refillInventory(medicineId: medicineId, amount: amount)
            if var current = self.medicine {
                current = MedicineDetailDTO(
                    id: current.id,
                    name: current.name,
                    dosageValue: current.dosageValue,
                    dosageUnit: current.dosageUnit,
                    type: current.type,
                    status: current.status,
                    startDate: current.startDate,
                    endDate: current.endDate,
                    ongoing: current.ongoing,
                    instructions: current.instructions,
                    schedule: current.schedule,
                    inventory: updatedInventory
                )
                self.medicine = current
            }
            showRefillSheet = false
            HapticService.shared.success()
            isActionInProgress = false
        } catch let apiError as APIError {
            isActionInProgress = false
            self.errorMessage = apiError.errorDescription
        } catch {
            isActionInProgress = false
            self.errorMessage = error.localizedDescription
        }
    }
    
    func correctInventory() async {
        guard let qty = Int(correctedQuantityText), qty >= 0 else { return }
        isActionInProgress = true
        errorMessage = nil
        
        do {
            let updatedInventory = try await inventoryRepository.updateInventory(medicineId: medicineId, quantity: qty)
            if var current = self.medicine {
                current = MedicineDetailDTO(
                    id: current.id,
                    name: current.name,
                    dosageValue: current.dosageValue,
                    dosageUnit: current.dosageUnit,
                    type: current.type,
                    status: current.status,
                    startDate: current.startDate,
                    endDate: current.endDate,
                    ongoing: current.ongoing,
                    instructions: current.instructions,
                    schedule: current.schedule,
                    inventory: updatedInventory
                )
                self.medicine = current
            }
            showCorrectionSheet = false
            HapticService.shared.success()
            isActionInProgress = false
        } catch let apiError as APIError {
            isActionInProgress = false
            self.errorMessage = apiError.errorDescription
        } catch {
            isActionInProgress = false
            self.errorMessage = error.localizedDescription
        }
    }
    
    func deleteMedicine() async -> Bool {
        isActionInProgress = true
        errorMessage = nil
        do {
            try await medicineRepository.deleteMedicine(id: medicineId)
            NotificationService.shared.cancelReminders(for: medicineId)
            HapticService.shared.success()
            isDeleted = true
            isActionInProgress = false
            return true
        } catch let apiError as APIError {
            isActionInProgress = false
            self.errorMessage = apiError.errorDescription
            return false
        } catch {
            isActionInProgress = false
            self.errorMessage = error.localizedDescription
            return false
        }
    }
}
