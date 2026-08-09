//
//  ListDetailsResponseDTO.swift
//  ExampleMVVM
//
//  Created by Aisha Hudasi on 20/01/1448 AH.
//
import Foundation

struct ListDetailsResponseDTO: Decodable {
    let id: Int
    let name: String
    let description: String?
    let itemCount: Int
    let items: [MoviesResponseDTO.MovieDTO]

    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case itemCount = "item_count"
        case items
    }
}

extension ListDetailsResponseDTO {
    func toDomain() -> [Movie] {
        items.map { $0.toDomain() }
    }
}
