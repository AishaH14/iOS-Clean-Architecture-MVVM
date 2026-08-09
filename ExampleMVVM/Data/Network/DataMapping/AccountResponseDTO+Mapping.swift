//
//  AccountResponseDTO+Mapping.swift
//  ExampleMVVM
//
//  Created by Aisha Hudasi on 13/01/1448 AH.
//

import Foundation

// MARK: - Data Transfer Object

struct AccountResponseDTO: Decodable {
    let id: Int
    let username: String
}

extension AccountResponseDTO {
    func toDomain() -> Account {
        Account(
            id: id,
            username: username
        )
    }
}
