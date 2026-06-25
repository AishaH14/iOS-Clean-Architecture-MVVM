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
}

final class UserDefaultsAuthSessionStorage: AuthSessionStorage {
    
    private enum Keys {
        static let sessionId = "session_id"
        static let guestSessionId = "guest_session_id"
    }
    
    func saveSessionId(_ sessionId: String) {
        UserDefaults.standard.set(sessionId, forKey: Keys.sessionId)
    }
    
    func getSessionId() -> String? {
        UserDefaults.standard.string(forKey: Keys.sessionId)
    }
    
    func saveGuestSessionId(_ guestSessionId: String) {
        UserDefaults.standard.set(guestSessionId, forKey: Keys.guestSessionId)
    }
    
    func getGuestSessionId() -> String? {
        UserDefaults.standard.string(forKey: Keys.guestSessionId)
    }
}
