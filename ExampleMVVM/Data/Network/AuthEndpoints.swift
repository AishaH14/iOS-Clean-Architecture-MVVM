//
//  AuthEndpoints.swift
//  ExampleMVVM
//
//  Created by Aisha Hudasi on 01/01/1448 AH.
//

import Foundation

struct AuthEndpoints {

    static func requestToken() -> Endpoint<RequestTokenResponseDTO> {
        Endpoint(
            path: "3/authentication/token/new",
            method: .get
        )
    }

    static func createSession(requestToken: String) -> Endpoint<CreateSessionResponseDTO> {
        Endpoint(
            path: "3/authentication/session/new",
            method: .post,
            headerParameters: [
                AuthConstants.contentTypeHeader: AuthConstants.applicationJSON,
                AuthConstants.acceptHeader: AuthConstants.applicationJSON
            ],
            bodyParameters: [
                AuthConstants.requestToken: requestToken
            ]
        )
    }

    static func guestSession() -> Endpoint<GuestSessionResponseDTO> {
        Endpoint(
            path: "3/authentication/guest_session/new",
            method: .get
        )
    }
    }

