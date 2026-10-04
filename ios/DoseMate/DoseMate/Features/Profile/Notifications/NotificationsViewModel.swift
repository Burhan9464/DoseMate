import SwiftUI
import UserNotifications

#if canImport(UIKit)
import UIKit
#endif

@MainActor
final class NotificationsViewModel: ObservableObject {
    @Published var authorizationStatus: UNAuthorizationStatus = .notDetermined
    @Published var pendingRequestsCount: Int = 0
    
    func checkStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                self?.authorizationStatus = settings.authorizationStatus
            }
        }
        
        UNUserNotificationCenter.current().getPendingNotificationRequests { [weak self] requests in
            DispatchQueue.main.async {
                self?.pendingRequestsCount = requests.count
            }
        }
    }
    
    func requestPermission() async {
        let granted = await NotificationService.shared.requestAuthorization()
        if granted {
            HapticService.shared.success()
        }
        checkStatus()
    }
    
    func openSystemSettings() {
        #if canImport(UIKit)
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString),
           UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl)
        }
        #endif
    }
}
