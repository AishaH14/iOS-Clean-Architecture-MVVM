//
//  CreateListResponseDTO.swift
//  ExampleMVVM
//
//  Created by Aisha Hudasi on 16/01/1448 AH.
//

import Foundation

struct CreateListResponseDTO: Decodable {
    let success: Bool
    let statusCode: Int
    let statusMessage: String
    let listId: Int?
    
    private enum CodingKeys: String, CodingKey {
        case success
        case statusCode = "status_code"
        case statusMessage = "status_message"
        case listId = "list_id"
    }
}
