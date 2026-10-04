import Foundation

/// Standard success envelope returned by the DoseMate Spring Boot API.
struct APIResponse<T: Codable>: Codable {
    let data: T?
    let message: String?
}

/// Standard error envelope returned by the backend on 4xx/5xx responses.
struct APIErrorResponse: Codable, Error {
    let code: String
    let message: String
    let details: [String: String]?
    let timestamp: String?
}
