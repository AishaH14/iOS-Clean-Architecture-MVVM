//
//  AuthResponseDTO.swift
//  ExampleMVVM
//
//  Created by Aisha Hudasi on 01/01/1448 AH.
//

import Foundation

// MARK: - Request Token
struct RequestTokenResponseDTO: Decodable {
    let success: Bool
    let expiresAt: String
    let requestToken: String

    enum CodingKeys: String, CodingKey {
        case success
        case expiresAt = "expires_at"
        case requestToken = "request_token"
    }
}

// MARK: - Create Session
struct CreateSessionResponseDTO: Decodable {
    let success: Bool
    let sessionId: String

    enum CodingKeys: String, CodingKey {
        case success
        case sessionId = "session_id"
    }
}

// MARK: - Guest Session
struct GuestSessionResponseDTO: Decodable {
    let success: Bool
    let guestSessionId: String
    let expiresAt: String

    enum CodingKeys: String, CodingKey {
        case success
        case guestSessionId = "guest_session_id"
        case expiresAt = "expires_at"
    }
}
