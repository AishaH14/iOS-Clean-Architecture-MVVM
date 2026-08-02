//
//  AuthSessionStorage.swift
//  ExampleMVVM
//
//  Created by Aisha Hudasi on 02/01/1448 AH.
//

import Foundation

protocol AuthSessionStorage {
    func saveSessionId(_ sessionId: String)
    func getSessionId() -> String?
    func saveGuestSessionId(_ guestSessionId: String)
    func getGuestSessionId() -> String?
    func removeSessionId()
    func removeGuestSessionId()
}

final class KeychainAuthSessionStorage: AuthSessionStorage {
    
    private enum Keys {
        static let sessionId = "session_id"
        static let guestSessionId = "guest_session_id"
    }
    private enum KeychainConstants {
        static let service = "com.examplemvvm.auth"
    }

    private let keychainStorage: KeychainStorage

    init(
        keychainStorage: KeychainStorage = KeychainStorage(
            service: KeychainConstants.service
        )
    ) {
        self.keychainStorage = keychainStorage
    }

    func saveSessionId(_ sessionId: String) {
        keychainStorage.save(
            sessionId,
            forKey: Keys.sessionId
        )
    }

    func getSessionId() -> String? {
        keychainStorage.getValue(
            forKey: Keys.sessionId
        )
    }
    func saveGuestSessionId(_ guestSessionId: String) {
        keychainStorage.save(
            guestSessionId,
            forKey: Keys.guestSessionId
        )
    }

    func getGuestSessionId() -> String? {
        keychainStorage.getValue(
            forKey: Keys.guestSessionId
        )
    }
    func removeSessionId() {
        keychainStorage.removeValue(forKey: Keys.sessionId)
    }
    func removeGuestSessionId() {
        keychainStorage.removeValue(forKey: Keys.guestSessionId)
    }
}
