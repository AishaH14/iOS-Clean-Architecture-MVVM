//
//  AccountRequestDTO.swift
//  ExampleMVVM
//
//  Created by Aisha Hudasi on 13/01/1448 AH.
//

import Foundation

struct AccountRequestDTO: Encodable {
    let sessionId: String
    
    private enum CodingKeys: String, CodingKey {
        case sessionId = "session_id"
    }
}
