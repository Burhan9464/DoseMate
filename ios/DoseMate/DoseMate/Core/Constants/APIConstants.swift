import Foundation

/// Defines network constants and environment endpoints for the DoseMate client.
enum APIConstants {
    /// Default development base URL targeting the local Spring Boot backend.
    /// Note: On iOS Simulator, `http://localhost:8080/api/v1` connects directly to the host machine.
    /// When testing on a physical iPhone over Wi-Fi, change this to the host IP address (e.g., `http://192.168.1.X:8080/api/v1`).
    static var baseURL: URL {
        #if DEBUG
        if let customURL = ProcessInfo.processInfo.environment["DOSEMATE_API_URL"],
           let url = URL(string: customURL) {
            return url
        }
        return URL(string: "http://localhost:8080/api/v1")!
        #else
        return URL(string: "https://api.dosemate.app/api/v1")!
        #endif
    }
    
    static let requestTimeout: TimeInterval = 15.0
    static let resourceTimeout: TimeInterval = 30.0
    
    enum Headers {
        static let authorization = "Authorization"
        static let contentType = "Content-Type"
        static let accept = "Accept"
        static let jsonApplication = "application/json"
    }
}
