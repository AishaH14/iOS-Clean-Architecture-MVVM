//
//  AuthSessionStorage.swift
//  ExampleMVVM
//
//  Created by Aisha Hudasi on 02/01/1448 AH.
//

import Foundation
import Security

protocol AuthSessionStorage {
    func saveSessionId(_ sessionId: String)
    func getSessionId() -> String?
    func saveGuestSessionId(_ guestSessionId: String)
    func getGuestSessionId() -> String?
}

final class UserDefaultsAuthSessionStorage: AuthSessionStorage {
    
    private enum Keys {
        static let sessionId = "session_id"
        static let guestSessionId = "guest_session_id"
    }
    private enum KeychainConstants {
        static let service = "com.examplemvvm.auth"
    }
    
    func saveSessionId(_ sessionId: String) {
        guard let data = sessionId.data(using: .utf8) else { return }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: KeychainConstants.service,
            kSecAttrAccount as String: Keys.sessionId
        ]
        
        let attributes: [String: Any] = [
            kSecValueData as String: data
        ]
        
        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        
        if status == errSecItemNotFound {
            var newItem = query
            newItem[kSecValueData as String] = data
            SecItemAdd(newItem as CFDictionary, nil)
        }
    }
    func getSessionId() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: KeychainConstants.service,
            kSecAttrAccount as String: Keys.sessionId,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let sessionId = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return sessionId
    }
    
    func saveGuestSessionId(_ guestSessionId: String) {
        UserDefaults.standard.set(guestSessionId, forKey: Keys.guestSessionId)
    }
    
    func getGuestSessionId() -> String? {
        UserDefaults.standard.string(forKey: Keys.guestSessionId)
    }
}
