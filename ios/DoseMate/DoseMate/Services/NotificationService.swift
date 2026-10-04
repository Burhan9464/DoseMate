import Foundation
import UserNotifications

/// Handles local medication reminders via Apple's UserNotifications framework.
final class NotificationService: NSObject, ObservableObject {
    static let shared = NotificationService()
    
    @Published var authorizationStatus: UNAuthorizationStatus = .notDetermined
    
    private let center = UNUserNotificationCenter.current()
    
    override private init() {
        super.init()
        checkAuthorizationStatus()
    }
    
    /// Checks current permission status without prompting.
    func checkAuthorizationStatus() {
        center.getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                self?.authorizationStatus = settings.authorizationStatus
            }
        }
    }
    
    /// Requests notification permissions from the user.
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            checkAuthorizationStatus()
            return granted
        } catch {
            checkAuthorizationStatus()
            return false
        }
    }
    
    /// Schedules local reminders for a medicine's active schedule using stable identifiers.
    func scheduleReminders(
        medicineId: Int64,
        medicineName: String,
        dosage: String,
        schedule: ScheduleDTO
    ) {
        // First cancel any existing reminders for this medicine to ensure no orphaned duplicates
        cancelReminders(for: medicineId)
        
        let weekdayMapping: [DayOfWeek: Int] = [
            .sunday: 1,
            .monday: 2,
            .tuesday: 3,
            .wednesday: 4,
            .thursday: 5,
            .friday: 6,
            .saturday: 7
        ]
        
        for day in schedule.days {
            guard let weekday = weekdayMapping[day] else { continue }
            
            for timeString in schedule.times {
                // Parse time components "HH:mm:ss"
                let components = timeString.split(separator: ":").compactMap { Int($0) }
                guard components.count >= 2 else { continue }
                
                let hour = components[0]
                let minute = components[1]
                
                let content = UNMutableNotificationContent()
                content.title = "Time for your \(medicineName)"
                content.body = "Dosage: \(dosage). Tap to mark as taken."
                content.sound = .default
                content.categoryIdentifier = AppConstants.NotificationCategory.doseReminder
                content.userInfo = [
                    "medicineId": medicineId,
                    "medicineName": medicineName,
                    "time": timeString
                ]
                
                var dateComponents = DateComponents()
                dateComponents.weekday = weekday
                dateComponents.hour = hour
                dateComponents.minute = minute
                dateComponents.second = 0
                
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                let identifier = "dose_\(medicineId)_\(day.rawValue)_\(hour)_\(minute)"
                
                let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
                center.add(request) { error in
                    if let error = error {
                        print("[NotificationService] Error scheduling notification \(identifier): \(error)")
                    }
                }
            }
        }
    }
    
    /// Cancels all scheduled local reminders for a given medicine.
    func cancelReminders(for medicineId: Int64) {
        center.getPendingNotificationRequests { [weak self] requests in
            let prefix = "dose_\(medicineId)_"
            let matchingIds = requests.filter { $0.identifier.hasPrefix(prefix) }.map { $0.identifier }
            if !matchingIds.isEmpty {
                self?.center.removePendingNotificationRequests(withIdentifiers: matchingIds)
            }
        }
    }
    
    /// Cancels all pending notifications across the entire application (e.g. on logout).
    func cancelAll() {
        center.removeAllPendingNotificationRequests()
    }
    
    /// Reconciles local reminders with the latest list of active medicines from the backend.
    func reconcileReminders(with medicines: [MedicineDetailDTO]) {
        // Collect all IDs that should be active
        let activeMedicines = medicines.filter { $0.status == .active }
        
        // Remove all and re-register to ensure clean slate matching authoritative server state
        center.removeAllPendingNotificationRequests()
        
        for medicine in activeMedicines {
            if let schedule = medicine.schedule {
                scheduleReminders(
                    medicineId: medicine.id,
                    medicineName: medicine.name,
                    dosage: medicine.formattedDosage,
                    schedule: schedule
                )
            }
        }
    }
}
