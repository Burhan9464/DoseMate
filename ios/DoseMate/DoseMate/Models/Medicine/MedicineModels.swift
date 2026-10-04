import Foundation
import SwiftUI

enum MedicineType: String, Codable, CaseIterable, Identifiable {
    case tablet = "TABLET"
    case capsule = "CAPSULE"
    case syrup = "SYRUP"
    case injection = "INJECTION"
    case drops = "DROPS"
    case cream = "CREAM"
    case supplement = "SUPPLEMENT"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .tablet: return "Tablet"
        case .capsule: return "Capsule"
        case .syrup: return "Syrup"
        case .injection: return "Injection"
        case .drops: return "Drops"
        case .cream: return "Cream"
        case .supplement: return "Supplement"
        }
    }
    
    var iconName: String {
        switch self {
        case .tablet: return "pills.fill"
        case .capsule: return "capsule.fill"
        case .syrup: return "cross.vial.fill"
        case .injection: return "syringe.fill"
        case .drops: return "drop.fill"
        case .cream: return "bandage.fill"
        case .supplement: return "leaf.fill"
        }
    }
}

enum MedicineStatus: String, Codable, CaseIterable, Identifiable {
    case active = "ACTIVE"
    case paused = "PAUSED"
    case completed = "COMPLETED"
    case deleted = "DELETED"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .active: return "Active"
        case .paused: return "Paused"
        case .completed: return "Completed"
        case .deleted: return "Deleted"
        }
    }
}

/// Summary representation for listing on the Medicines screen.
struct MedicineSummaryDTO: Codable, Identifiable, Equatable {
    let id: Int64
    let name: String
    let dosageValue: Double
    let dosageUnit: String
    let type: MedicineType
    let status: MedicineStatus
    let scheduleSummary: String?
    let inventoryRemaining: Int?
    let isLowStock: Bool?
    
    var formattedDosage: String {
        let valueStr = dosageValue.truncatingRemainder(dividingBy: 1) == 0
            ? String(format: "%.0f", dosageValue)
            : String(format: "%.1f", dosageValue)
        return "\(valueStr) \(dosageUnit)"
    }
}

/// Comprehensive representation for the Medicine Details screen.
struct MedicineDetailDTO: Codable, Identifiable, Equatable {
    let id: Int64
    let name: String
    let dosageValue: Double
    let dosageUnit: String
    let type: MedicineType
    let status: MedicineStatus
    let startDate: String
    let endDate: String?
    let ongoing: Bool
    let instructions: String?
    let schedule: ScheduleDTO?
    let inventory: InventoryDTO?
    
    var formattedDosage: String {
        let valueStr = dosageValue.truncatingRemainder(dividingBy: 1) == 0
            ? String(format: "%.0f", dosageValue)
            : String(format: "%.1f", dosageValue)
        return "\(valueStr) \(dosageUnit)"
    }
}

/// Payload sent when creating or editing a medicine.
struct MedicineCreateUpdateDTO: Codable {
    let name: String
    let dosageValue: Double
    let dosageUnit: String
    let type: MedicineType
    let startDate: String
    let endDate: String?
    let ongoing: Bool
    let instructions: String?
    let schedule: ScheduleDTO
    let inventory: InventoryDTO
}
