//
//  AddMovieToListRequestDTO.swift
//  ExampleMVVM
//
//  Created by Aisha Hudasi on 20/01/1448 AH.
//

import Foundation

struct AddMovieToListRequestDTO: Encodable {
    let mediaId: Int
    
    private enum CodingKeys: String, CodingKey {
        case mediaId = "media_id"
    }
}
