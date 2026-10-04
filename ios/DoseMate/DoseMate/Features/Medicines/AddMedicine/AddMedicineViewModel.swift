import SwiftUI

enum AddMedicineStep: Int, CaseIterable {
    case information = 1
    case schedule = 2
    case inventory = 3
}

@MainActor
final class AddMedicineViewModel: ObservableObject {
    @Published var currentStep: AddMedicineStep = .information
    
    // Step 1: Information
    @Published var name: String = ""
    @Published var dosageValueText: String = "1"
    @Published var dosageUnit: String = "tablet"
    @Published var selectedType: MedicineType = .tablet
    @Published var startDate: Date = Date()
    @Published var endDate: Date = Calendar.current.date(byAdding: .day, value: 14, to: Date()) ?? Date()
    @Published var isOngoing: Bool = true
    @Published var instructions: String = ""
    
    // Step 2: Schedule
    @Published var frequencyMode: FrequencyMode = .onceDaily
    @Published var selectedDays: Set<DayOfWeek> = Set(DayOfWeek.allCases)
    @Published var scheduledTimes: [Date] = [
        Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date()) ?? Date()
    ]
    
    // Step 3: Inventory
    @Published var inventoryQuantityText: String = "30"
    @Published var inventoryUnit: String = "tablets"
    @Published var lowStockThresholdText: String = "5"
    
    // Form validation errors
    @Published var nameError: String? = nil
    @Published var dosageError: String? = nil
    @Published var scheduleError: String? = nil
    @Published var inventoryError: String? = nil
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    private let medicineRepository: MedicineRepositoryProtocol
    
    init(medicineRepository: MedicineRepositoryProtocol = MedicineRepository()) {
        self.medicineRepository = medicineRepository
    }
    
    func validateStep1() -> Bool {
        nameError = nil
        dosageError = nil
        errorMessage = nil
        var isValid = true
        
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        if trimmedName.isEmpty {
            nameError = "Medicine name is required."
            isValid = false
        }
        
        guard let val = Double(dosageValueText), val > 0 else {
            dosageError = "Enter a positive dosage amount."
            return false
        }
        
        if !isOngoing && endDate < startDate {
            errorMessage = "End date cannot precede start date."
            isValid = false
        }
        
        return isValid
    }
    
    func validateStep2() -> Bool {
        scheduleError = nil
        errorMessage = nil
        
        if selectedDays.isEmpty {
            scheduleError = "Please select at least one active day."
            return false
        }
        
        if frequencyMode == .multipleDaily && scheduledTimes.count < 2 {
            scheduleError = "Multiple-times mode requires at least two distinct times."
            return false
        }
        
        return true
    }
    
    func validateStep3() -> Bool {
        inventoryError = nil
        guard let qty = Int(inventoryQuantityText), qty >= 0 else {
            inventoryError = "Starting quantity must be 0 or greater."
            return false
        }
        guard let thresh = Int(lowStockThresholdText), thresh >= 0 else {
            inventoryError = "Threshold must be 0 or greater."
            return false
        }
        return true
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
    
    func saveMedicine() async -> Bool {
        guard validateStep1() && validateStep2() && validateStep3() else { return false }
        
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
                quantity: Int(inventoryQuantityText) ?? 30,
                unit: inventoryUnit.trimmingCharacters(in: .whitespaces).isEmpty ? "units" : inventoryUnit,
                lowStockThreshold: Int(lowStockThresholdText) ?? 5,
                isLowStock: nil
            )
            
            let createDto = MedicineCreateUpdateDTO(
                name: name.trimmingCharacters(in: .whitespaces),
                dosageValue: Double(dosageValueText) ?? 1.0,
                dosageUnit: dosageUnit.trimmingCharacters(in: .whitespaces),
                type: selectedType,
                startDate: startDate.toAPIDateString,
                endDate: isOngoing ? nil : endDate.toAPIDateString,
                ongoing: isOngoing,
                instructions: instructions.trimmingCharacters(in: .whitespaces).isEmpty ? nil : instructions,
                schedule: scheduleDto,
                inventory: inventoryDto
            )
            
            let created = try await medicineRepository.createMedicine(request: createDto)
            
            // Schedule local notifications for this newly created medicine
            if let schedule = created.schedule {
                NotificationService.shared.scheduleReminders(
                    medicineId: created.id,
                    medicineName: created.name,
                    dosage: created.formattedDosage,
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
