import Foundation

extension Date {
    /// Formatter for API dates (YYYY-MM-DD).
    static let apiDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        return formatter
    }()
    
    /// Formatter for API times (HH:mm:ss).
    static let apiTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        return formatter
    }()
    
    /// ISO-8601 Formatter for timestamp fields.
    static let iso8601Full: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
    
    /// Formats Date into "yyyy-MM-dd" string for API payloads.
    var toAPIDateString: String {
        Date.apiDateFormatter.string(from: self)
    }
    
    /// Formats Date into readable localized time (e.g. "8:00 AM" or "08:00").
    var toTimeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }
    
    /// Formats Date into readable month & day (e.g. "Oct 5, 2026").
    var toMediumDateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: self)
    }
    
    /// Returns relative date heading ("Today", "Yesterday", or "Monday, Oct 5").
    var relativeDayHeader: String {
        let calendar = Calendar.current
        if calendar.isDateInToday(self) {
            return "Today"
        } else if calendar.isDateInYesterday(self) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE, MMM d"
            return formatter.string(from: self)
        }
    }
    
    /// Checks if date is on the same calendar day as another date.
    func isSameDay(as other: Date) -> Bool {
        Calendar.current.isDate(self, inSameDayAs: other)
    }
}

extension String {
    /// Parses an ISO8601 timestamp string into a Date.
    var toDateFromISO8601: Date? {
        if let date = Date.iso8601Full.date(from: self) {
            return date
        }
        let fallback = ISO8601DateFormatter()
        fallback.formatOptions = [.withInternetDateTime]
        return fallback.date(from: self)
    }
    
    /// Parses a "yyyy-MM-dd" string into a Date.
    var toDateFromAPIDate: Date? {
        Date.apiDateFormatter.date(from: self)
    }
    
    /// Formats a time string like "08:00:00" to localized short time string "8:00 AM".
    var formattedTimeString: String {
        guard let date = Date.apiTimeFormatter.date(from: self) else {
            return self
        }
        return date.toTimeString
    }
}
