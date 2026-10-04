import Foundation
import SwiftUI

enum DoseStatus: String, Codable, CaseIterable, Identifiable {
    case pending = "PENDING"
    case taken = "TAKEN"
    case skipped = "SKIPPED"
    case missed = "MISSED"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .pending: return "Pending"
        case .taken: return "Taken"
        case .skipped: return "Skipped"
        case .missed: return "Missed"
        }
    }
    
    var color: Color {
        switch self {
        case .taken: return ColorTokens.statusTaken
        case .pending: return ColorTokens.statusDue
        case .skipped: return ColorTokens.statusSkipped
        case .missed: return ColorTokens.statusMissed
        }
    }
    
    var subtleBackgroundColor: Color {
        switch self {
        case .taken: return ColorTokens.statusTakenSubtle
        case .pending: return ColorTokens.statusDueSubtle
        case .skipped: return ColorTokens.statusSkippedSubtle
        case .missed: return ColorTokens.statusMissedSubtle
        }
    }
    
    var iconName: String {
        switch self {
        case .taken: return "checkmark.circle.fill"
        case .pending: return "clock.fill"
        case .skipped: return "forward.fill"
        case .missed: return "xmark.circle.fill"
        }
    }
}

/// Representation of an individual scheduled dose.
struct DoseRecordDTO: Codable, Identifiable, Equatable {
    let id: Int64
    let medicineId: Int64?
    let medicineName: String
    let dosage: String
    let type: MedicineType?
    let scheduledAt: String
    var status: DoseStatus
    var actedAt: String?
    let priority: String?
    
    var scheduledDate: Date? {
        scheduledAt.toDateFromISO8601
    }
    
    var formattedTime: String {
        if let date = scheduledDate {
            return date.toTimeString
        }
        return scheduledAt
    }
}

/// Response returned by the transactional Drag-the-Pill endpoint `POST /doses/{id}/taken`.
struct DoseTakenResponseDTO: Codable {
    let dose: DoseRecordDTO
    let remainingInventory: Int
    let isLowStock: Bool
}

/// Helper struct for grouping doses by calendar day in the History screen.
struct DoseHistoryGroup: Identifiable {
    var id: String { dateHeader }
    let dateHeader: String
    let doses: [DoseRecordDTO]
}
