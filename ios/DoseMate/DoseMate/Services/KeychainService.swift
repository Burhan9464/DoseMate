import Foundation

protocol KeychainServiceProtocol {
    func saveToken(_ token: String) -> Bool
    func getToken() -> String?
    func deleteToken() -> Bool
    func hasToken() -> Bool
}

final class KeychainService: KeychainServiceProtocol {
    static let shared = KeychainService()
    
    private let tokenKey = AppConstants.StorageKeys.authTokenKey
    
    private init() {}
    
    func saveToken(_ token: String) -> Bool {
        KeychainHelper.shared.save(key: tokenKey, value: token)
    }
    
    func getToken() -> String? {
        KeychainHelper.shared.read(key: tokenKey)
    }
    
    func deleteToken() -> Bool {
        KeychainHelper.shared.delete(key: tokenKey)
    }
    
    func hasToken() -> Bool {
        guard let token = getToken(), !token.isEmpty else {
            return false
        }
        return true
    }
}
