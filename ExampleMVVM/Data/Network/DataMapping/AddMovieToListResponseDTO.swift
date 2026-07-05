//
//  AddMovieToListResponseDTO.swift
//  ExampleMVVM
//
//  Created by Aisha Hudasi on 20/01/1448 AH.
//

import Foundation

struct AddMovieToListResponseDTO: Decodable {
    let success: Bool
    let statusCode: Int
    let statusMessage: String
    
    private enum CodingKeys: String, CodingKey {
        case success
        case statusCode = "status_code"
        case statusMessage = "status_message"
    }
}
