import Foundation
import Security

/// Thread-safe wrapper for Apple Security Keychain services.
final class KeychainHelper {
    static let shared = KeychainHelper()
    
    private init() {}
    
    /// Saves or updates a UTF-8 string into Keychain.
    @discardableResult
    func save(key: String, value: String) -> Bool {
        guard let data = value.data(using: .utf8) else { return false }
        return save(key: key, data: data)
    }
    
    /// Saves or updates Data into Keychain.
    @discardableResult
    func save(key: String, data: Data) -> Bool {
        // Query to check if the item already exists
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        let attributesToUpdate: [String: Any] = [
            kSecValueData as String: data
        ]
        
        let status = SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)
        
        if status == errSecSuccess {
            return true
        } else if status == errSecItemNotFound {
            var newItem = query
            newItem[kSecValueData as String] = data
            newItem[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlock
            let addStatus = SecItemAdd(newItem as CFDictionary, nil)
            return addStatus == errSecSuccess
        } else {
            return false
        }
    }
    
    /// Reads a UTF-8 string from Keychain.
    func read(key: String) -> String? {
        guard let data = readData(key: key) else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    /// Reads raw Data from Keychain.
    func readData(key: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: kCFBooleanTrue as Any,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        if status == errSecSuccess, let data = dataTypeRef as? Data {
            return data
        }
        return nil
    }
    
    /// Deletes an item from Keychain.
    @discardableResult
    func delete(key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }
}
