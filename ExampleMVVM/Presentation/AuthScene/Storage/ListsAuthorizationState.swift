//
//  ListsAuthorizationState.swift
//  ExampleMVVM
//
//  Created by Aisha Hudasi on 27/01/1448 AH.
//

import Foundation

enum ListsAuthorizationState {
    case authenticated(sessionId: String)
    case guest
    case missing
}

extension AuthSessionStorage {
    func listsAuthorizationState() -> ListsAuthorizationState {
        if let sessionId = getSessionId() {
            return .authenticated(sessionId: sessionId)
        }

        if getGuestSessionId() != nil {
            return .guest
        }

        return .missing
    }
}
