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

final class KeychainAuthSessionStorage: AuthSessionStorage {
    
    private enum Keys {
        static let sessionId = "session_id"
        static let guestSessionId = "guest_session_id"
    }
    private enum KeychainConstants {
        static let service = "com.examplemvvm.auth"
    }
    
    func saveSessionId(_ sessionId: String) {
        save(
            sessionId,
            forKey: Keys.sessionId
        )
    }

    func getSessionId() -> String? {
        getValue(
            forKey: Keys.sessionId
        )
    }
    
    func saveGuestSessionId(_ guestSessionId: String) {
        save(
            guestSessionId,
            forKey: Keys.guestSessionId
        )
    }
    
    func getGuestSessionId() -> String? {
        getValue(
            forKey: Keys.guestSessionId
        )
    }
}
// MARK: - Private
private extension KeychainAuthSessionStorage {
    
    func save(
        _ value: String,
        forKey key: String
    ) {
        guard let data = value.data(using: .utf8) else { return }
        
        let query = makeQuery(forKey: key)
        
        let attributes: [String: Any] = [
            kSecValueData as String: data
        ]
        
        let status = SecItemUpdate(
            query as CFDictionary,
            attributes as CFDictionary
        )
        
        if status == errSecItemNotFound {
            var newItem = query
            newItem[kSecValueData as String] = data
            SecItemAdd(newItem as CFDictionary, nil)
        }
    }
    
    func getValue(forKey key: String) -> String? {
        var query = makeQuery(forKey: key)
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        
        var result: AnyObject?
        let status = SecItemCopyMatching(
            query as CFDictionary,
            &result
        )
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let value = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return value
    }
    
    func makeQuery(forKey key: String) -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: KeychainConstants.service,
            kSecAttrAccount as String: key
        ]
    }
}
