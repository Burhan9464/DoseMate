import Foundation

enum FrequencyMode: String, Codable, CaseIterable, Identifiable {
    case onceDaily = "ONCE_DAILY"
    case multipleDaily = "MULTIPLE_DAILY"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .onceDaily: return "Once a Day"
        case .multipleDaily: return "Multiple Times a Day"
        }
    }
}

enum DayOfWeek: String, Codable, CaseIterable, Identifiable {
    case monday = "MONDAY"
    case tuesday = "TUESDAY"
    case wednesday = "WEDNESDAY"
    case thursday = "THURSDAY"
    case friday = "FRIDAY"
    case saturday = "SATURDAY"
    case sunday = "SUNDAY"
    
    var id: String { rawValue }
    
    var shortName: String {
        switch self {
        case .monday: return "Mon"
        case .tuesday: return "Tue"
        case .wednesday: return "Wed"
        case .thursday: return "Thu"
        case .friday: return "Fri"
        case .saturday: return "Sat"
        case .sunday: return "Sun"
        }
    }
    
    var singleLetter: String {
        switch self {
        case .monday: return "M"
        case .tuesday: return "T"
        case .wednesday: return "W"
        case .thursday: return "T"
        case .friday: return "F"
        case .saturday: return "S"
        case .sunday: return "S"
        }
    }
}

struct ScheduleDTO: Codable, Equatable {
    var frequencyMode: FrequencyMode
    var days: [DayOfWeek]
    var times: [String] // e.g. ["08:00:00", "20:00:00"]
}
