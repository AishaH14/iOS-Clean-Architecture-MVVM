//
//  KeychainStorage.swift
//  ExampleMVVM
//
//  Created by Aisha Hudasi on 24/01/1448 AH.
//

import Foundation
import Security

final class KeychainStorage {

    private let service: String

    init(service: String) {
        self.service = service
    }
    @discardableResult
    func save(_ value: String, forKey key: String) -> Bool {
        guard let data = value.data(using: .utf8) else { return false }

        let query = makeKeychainQuery(forKey: key)

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
           let addStatus = SecItemAdd(newItem as CFDictionary,nil)
            return addStatus == errSecSuccess
        }
        return status == errSecSuccess
    }

    func getValue(forKey key: String) -> String? {
        var query = makeKeychainQuery(forKey: key)

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
    @discardableResult
    func removeValue(forKey key: String) -> Bool {
        let query = makeKeychainQuery(forKey: key)
        let status = SecItemDelete(query as CFDictionary)
                return status == errSecSuccess || status == errSecItemNotFound
            }
    private func makeKeychainQuery(
        forKey key: String
    ) -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
    }
}
