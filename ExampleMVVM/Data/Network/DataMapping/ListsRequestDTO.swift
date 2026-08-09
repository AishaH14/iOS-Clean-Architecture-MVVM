//
//  ListsRequestDTO.swift
//  ExampleMVVM
//
//  Created by Aisha Hudasi on 13/01/1448 AH.
//

import Foundation

struct ListsRequestDTO: Encodable {
    let sessionId: String
    let page: Int
    
    private enum CodingKeys: String, CodingKey {
        case sessionId = "session_id"
        case page
    }
}
