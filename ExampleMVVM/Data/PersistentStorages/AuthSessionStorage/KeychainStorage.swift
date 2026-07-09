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

    func save(
        _ value: String,
        forKey key: String
    ) {
        guard let data = value.data(using: .utf8) else { return }

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
            SecItemAdd(
                newItem as CFDictionary,
                nil
            )
        }
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
