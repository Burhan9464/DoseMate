import Foundation

struct DashboardDTO: Codable {
    let greeting: String
    let dailyProgress: DailyProgressDTO
    let currentDose: DoseRecordDTO?
    let nextUp: NextUpDTO?
    let needsAttention: [AttentionItemDTO]
}

struct DailyProgressDTO: Codable {
    let takenDoses: Int
    let totalScheduledDoses: Int
    let percentage: Int
    let skippedDoses: Int
    
    var progressFraction: Double {
        guard totalScheduledDoses > 0 else { return 0.0 }
        return Double(takenDoses) / Double(totalScheduledDoses)
    }
}

struct NextUpDTO: Codable {
    let medicineName: String
    let dosage: String
    let scheduledAt: String
    
    var scheduledDate: Date? {
        scheduledAt.toDateFromISO8601
    }
    
    var formattedTime: String {
        scheduledDate?.toTimeString ?? scheduledAt
    }
}

struct AttentionItemDTO: Codable, Identifiable {
    var id: String { "\(type)_\(medicineId ?? 0)_\(message)" }
    let type: String
    let medicineId: Int64?
    let medicineName: String?
    let remaining: Int?
    let threshold: Int?
    let message: String
}
