import SwiftUI

@MainActor
final class EditMedicineViewModel: ObservableObject {
    let medicineId: Int64
    
    @Published var name: String
    @Published var dosageValueText: String
    @Published var dosageUnit: String
    @Published var selectedType: MedicineType
    @Published var startDate: Date
    @Published var endDate: Date
    @Published var isOngoing: Bool
    @Published var instructions: String
    
    @Published var frequencyMode: FrequencyMode
    @Published var selectedDays: Set<DayOfWeek>
    @Published var scheduledTimes: [Date]
    
    @Published var inventoryQuantityText: String
    @Published var inventoryUnit: String
    @Published var lowStockThresholdText: String
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    private let medicineRepository: MedicineRepositoryProtocol
    
    init(medicine: MedicineDetailDTO, medicineRepository: MedicineRepositoryProtocol = MedicineRepository()) {
        self.medicineId = medicine.id
        self.medicineRepository = medicineRepository
        
        self.name = medicine.name
        self.dosageValueText = "\(medicine.dosageValue)"
        self.dosageUnit = medicine.dosageUnit
        self.selectedType = medicine.type
        self.startDate = medicine.startDate.toDateFromAPIDate ?? Date()
        self.endDate = medicine.endDate?.toDateFromAPIDate ?? Calendar.current.date(byAdding: .day, value: 14, to: Date()) ?? Date()
        self.isOngoing = medicine.ongoing
        self.instructions = medicine.instructions ?? ""
        
        if let schedule = medicine.schedule {
            self.frequencyMode = schedule.frequencyMode
            self.selectedDays = Set(schedule.days)
            self.scheduledTimes = schedule.times.compactMap { Date.apiTimeFormatter.date(from: $0) }
            if self.scheduledTimes.isEmpty {
                self.scheduledTimes = [Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date()) ?? Date()]
            }
        } else {
            self.frequencyMode = .onceDaily
            self.selectedDays = Set(DayOfWeek.allCases)
            self.scheduledTimes = [Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date()) ?? Date()]
        }
        
        if let inventory = medicine.inventory {
            self.inventoryQuantityText = "\(inventory.quantity)"
            self.inventoryUnit = inventory.unit
            self.lowStockThresholdText = "\(inventory.lowStockThreshold)"
        } else {
            self.inventoryQuantityText = "30"
            self.inventoryUnit = "tablets"
            self.lowStockThresholdText = "5"
        }
    }
    
    func addScheduledTime() {
        let newTime = Calendar.current.date(bySettingHour: 20, minute: 0, second: 0, of: Date()) ?? Date()
        scheduledTimes.append(newTime)
    }
    
    func removeScheduledTime(at index: Int) {
        if scheduledTimes.count > 1 {
            scheduledTimes.remove(at: index)
        }
    }
    
    func updateMedicine() async -> Bool {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Medicine name is required."
            return false
        }
        guard let dosageVal = Double(dosageValueText), dosageVal > 0 else {
            errorMessage = "Invalid dosage amount."
            return false
        }
        guard !selectedDays.isEmpty else {
            errorMessage = "At least one day must be selected."
            return false
        }
        if frequencyMode == .multipleDaily && scheduledTimes.count < 2 {
            errorMessage = "Multiple-times mode requires at least two times."
            return false
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let sortedDays = DayOfWeek.allCases.filter { selectedDays.contains($0) }
            let formattedTimes = scheduledTimes.map { Date.apiTimeFormatter.string(from: $0) }
            
            let scheduleDto = ScheduleDTO(
                frequencyMode: frequencyMode,
                days: sortedDays,
                times: formattedTimes
            )
            
            let inventoryDto = InventoryDTO(
                id: nil,
                quantity: Int(inventoryQuantityText) ?? 0,
                unit: inventoryUnit,
                lowStockThreshold: Int(lowStockThresholdText) ?? 5,
                isLowStock: nil
            )
            
            let updateDto = MedicineCreateUpdateDTO(
                name: name.trimmingCharacters(in: .whitespaces),
                dosageValue: dosageVal,
                dosageUnit: dosageUnit.trimmingCharacters(in: .whitespaces),
                type: selectedType,
                startDate: startDate.toAPIDateString,
                endDate: isOngoing ? nil : endDate.toAPIDateString,
                ongoing: isOngoing,
                instructions: instructions.trimmingCharacters(in: .whitespaces).isEmpty ? nil : instructions,
                schedule: scheduleDto,
                inventory: inventoryDto
            )
            
            let updated = try await medicineRepository.updateMedicine(id: medicineId, request: updateDto)
            
            // Reconcile notifications with new schedule
            if let schedule = updated.schedule {
                NotificationService.shared.scheduleReminders(
                    medicineId: updated.id,
                    medicineName: updated.name,
                    dosage: updated.formattedDosage,
                    schedule: schedule
                )
            }
            
            HapticService.shared.success()
            isLoading = false
            return true
        } catch let apiError as APIError {
            isLoading = false
            self.errorMessage = apiError.errorDescription
            return false
        } catch {
            isLoading = false
            self.errorMessage = error.localizedDescription
            return false
        }
    }
}
