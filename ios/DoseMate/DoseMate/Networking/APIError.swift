import Foundation

/// Strongly typed errors encountered during network and API operations.
enum APIError: LocalizedError, Equatable {
    case invalidURL
    case networkUnavailable
    case unauthorized
    case forbidden
    case notFound(String)
    case conflict(code: String, message: String)
    case businessRule(code: String, message: String, details: [String: String]?)
    case serverError(statusCode: Int, message: String)
    case decodingError(String)
    case sessionExpired
    case unknown(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The requested URL is invalid."
        case .networkUnavailable:
            return "Internet connection appears to be offline. Please check your connection."
        case .unauthorized:
            return "Invalid email or password. Please verify your credentials."
        case .forbidden:
            return "You do not have permission to access this resource."
        case .notFound(let resource):
            return "\(resource) was not found."
        case .conflict(let code, let serverMsg):
            return localizedMessage(for: code, fallback: serverMsg)
        case .businessRule(let code, let serverMsg, let details):
            if let details = details, !details.isEmpty {
                return details.values.joined(separator: "\n")
            }
            return localizedMessage(for: code, fallback: serverMsg)
        case .serverError(let statusCode, _):
            return "Server encountered an error (\(statusCode)). Please try again shortly."
        case .decodingError(let details):
            return "Failed to process data from server: \(details)"
        case .sessionExpired:
            return "Your session has expired. Please log in again."
        case .unknown(let message):
            return message
        }
    }
    
    /// Translates machine-readable error codes into friendly user messages.
    private func localizedMessage(for code: String, fallback: String) -> String {
        switch code {
        case "DUPLICATE_EMAIL":
            return "An account with this email address already exists."
        case "INVALID_CREDENTIALS":
            return "Incorrect email or password. Please try again."
        case "DOSE_ALREADY_COMPLETED":
            return "This dose has already been marked as taken."
        case "DOSE_NOT_PENDING":
            return "This dose cannot be updated in its current status."
        case "UNDO_WINDOW_EXPIRED":
            return "The 15-minute window to undo this action has passed."
        case "INSUFFICIENT_INVENTORY":
            return "Cannot take dose: medicine inventory is depleted."
        case "MEDICINE_ALREADY_PAUSED":
            return "This medication is already paused."
        case "MEDICINE_ALREADY_ACTIVE":
            return "This medication is already active."
        case "VALIDATION_FAILED":
            return "Please check the highlighted fields and try again."
        default:
            return fallback.isEmpty ? "An unexpected error occurred." : fallback
        }
    }
    
    static func == (lhs: APIError, rhs: APIError) -> Bool {
        lhs.errorDescription == rhs.errorDescription
    }
}
