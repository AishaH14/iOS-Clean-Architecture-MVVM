//
//  ListsResponseDTO+Mapping.swift
//  ExampleMVVM
//
//  Created by Aisha Hudasi on 13/01/1448 AH.
//

import Foundation

// MARK: - Data Transfer Object

struct ListsResponseDTO: Decodable {
    private enum CodingKeys: String, CodingKey {
        case page
        case totalPages = "total_pages"
        case lists = "results"
    }
    
    let page: Int
    let totalPages: Int
    let lists: [ListDTO]
}

extension ListsResponseDTO {
    struct ListDTO: Decodable {
        private enum CodingKeys: String, CodingKey {
            case id
            case name
            case description
            case itemCount = "item_count"
            case posterPath = "poster_path"
        }
        
        let id: Int
        let name: String
        let description: String?
        let itemCount: Int
        let posterPath: String?
    }
}
extension ListsResponseDTO {
    func toDomain() -> [MovieList] {
        lists.map { $0.toDomain() }
    }
}

extension ListsResponseDTO.ListDTO {
    func toDomain() -> MovieList {
        MovieList(
            id: id,
            name: name,
            description: description,
            itemCount: itemCount,
            posterPath: posterPath
        )
    }
}
