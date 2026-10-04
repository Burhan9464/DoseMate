import Foundation

/// Application-wide constants, user default keys, and timing thresholds.
enum AppConstants {
    static let appName = "DoseMate"
    static let appVersion = "1.0.0 (Build 1)"
    
    enum StorageKeys {
        static let authTokenKey = "com.dosemate.auth.token"
        static let currentUserKey = "com.dosemate.auth.user"
        static let onboardingCompletedKey = "com.dosemate.onboarding.completed"
        static let guideCompletedKey = "com.dosemate.guide.completed"
        static let lastSyncDateKey = "com.dosemate.sync.last_date"
    }
    
    enum Undo {
        /// The window in minutes during which a skipped dose can be undone.
        static let windowMinutes: Int = 15
        static let windowSeconds: TimeInterval = 15 * 60
    }
    
    enum NotificationCategory {
        static let doseReminder = "DOSE_REMINDER_CATEGORY"
        static let actionTake = "DOSE_ACTION_TAKE"
        static let actionSkip = "DOSE_ACTION_SKIP"
    }
}
