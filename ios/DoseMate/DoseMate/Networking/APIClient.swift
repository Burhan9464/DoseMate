import Foundation

extension Notification.Name {
    static let userSessionExpired = Notification.Name("com.dosemate.session.expired")
}

protocol APIClientProtocol {
    func request<T: Codable>(_ endpoint: APIEndpoint) async throws -> T
}

final class APIClient: APIClientProtocol {
    static let shared = APIClient()
    
    private let session: URLSession
    private let decoder: JSONDecoder
    
    init(session: URLSession = .shared) {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = APIConstants.requestTimeout
        configuration.timeoutIntervalForResource = APIConstants.resourceTimeout
        self.session = URLSession(configuration: configuration)
        
        self.decoder = JSONDecoder()
    }
    
    func request<T: Codable>(_ endpoint: APIEndpoint) async throws -> T {
        guard var urlComponents = URLComponents(url: APIConstants.baseURL.appendingPathComponent(endpoint.path), resolvingAgainstBaseURL: true) else {
            throw APIError.invalidURL
        }
        
        if let queryItems = endpoint.queryItems, !queryItems.isEmpty {
            urlComponents.queryItems = queryItems
        }
        
        guard let url = urlComponents.url else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.setValue(APIConstants.Headers.jsonApplication, forHTTPHeaderField: APIConstants.Headers.contentType)
        request.setValue(APIConstants.Headers.jsonApplication, forHTTPHeaderField: APIConstants.Headers.accept)
        
        if endpoint.requiresAuth {
            if let token = KeychainHelper.shared.read(key: AppConstants.StorageKeys.authTokenKey) {
                request.setValue("Bearer \(token)", forHTTPHeaderField: APIConstants.Headers.authorization)
            } else {
                throw APIError.unauthorized
            }
        }
        
        if let body = endpoint.body {
            request.httpBody = body
        }
        
        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: request)
        } catch let urlError as URLError {
            if urlError.code == .notConnectedToInternet || urlError.code == .networkConnectionLost {
                throw APIError.networkUnavailable
            }
            throw APIError.unknown(urlError.localizedDescription)
        } catch {
            throw APIError.unknown(error.localizedDescription)
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.unknown("Invalid server response")
        }
        
        // Handle Session Expiration
        if httpResponse.statusCode == 401 {
            KeychainHelper.shared.delete(key: AppConstants.StorageKeys.authTokenKey)
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .userSessionExpired, object: nil)
            }
            throw APIError.sessionExpired
        }
        
        // Handle Error Status Codes
        if httpResponse.statusCode >= 400 {
            if let errorResponse = try? decoder.decode(APIErrorResponse.self, from: data) {
                if httpResponse.statusCode == 409 {
                    throw APIError.conflict(code: errorResponse.code, message: errorResponse.message)
                } else if httpResponse.statusCode == 404 {
                    throw APIError.notFound(errorResponse.message)
                } else {
                    throw APIError.businessRule(code: errorResponse.code, message: errorResponse.message, details: errorResponse.details)
                }
            } else {
                if httpResponse.statusCode >= 500 {
                    throw APIError.serverError(statusCode: httpResponse.statusCode, message: "Internal server error")
                } else {
                    throw APIError.unknown("Request failed with status code \(httpResponse.statusCode)")
                }
            }
        }
        
        // Successful Response Processing
        do {
            // First attempt decoding as the standard APIResponse envelope
            if let envelope = try? decoder.decode(APIResponse<T>.self, from: data), let payload = envelope.data {
                return payload
            }
            // Fallback to decoding T directly if not wrapped
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decodingError(error.localizedDescription)
        }
    }
}
