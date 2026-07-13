//
//  ListsRepositoryError.swift
//  ExampleMVVM
//
//  Created by Aisha Hudasi on 21/01/1448 AH.
//

import Foundation

enum ListsRepositoryError: LocalizedError {
    case apiError(code: Int, message: String)

    var errorDescription: String? {
        switch self {
        case .apiError(_, let message):
            return message
        }
    }
}
