//
//  CreateListSessionRequestDTO.swift
//  ExampleMVVM
//
//  Created by Aisha Hudasi on 16/01/1448 AH.
//
import Foundation

struct CreateListSessionRequestDTO: Encodable {
    let sessionId: String
    
    private enum CodingKeys: String, CodingKey {
        case sessionId = "session_id"
    }
}
