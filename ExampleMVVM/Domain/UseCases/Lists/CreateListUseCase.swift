//
//  CreateListUseCase.swift
//  ExampleMVVM
//
//  Created by Aisha Hudasi on 16/01/1448 AH.
//

import Foundation

protocol CreateListUseCase {
    @discardableResult
    func execute(
        sessionId: String,
        name: String,
        description: String,
        completion: @escaping (Result<Int, Error>) -> Void
    ) -> Cancellable?
}

final class DefaultCreateListUseCase: CreateListUseCase {
    
    private let listsRepository: ListsRepository
    
    init(listsRepository: ListsRepository) {
        self.listsRepository = listsRepository
    }
    
    @discardableResult
    func execute(
        sessionId: String,
        name: String,
        description: String,
        completion: @escaping (Result<Int, Error>) -> Void
    ) -> Cancellable? {
        listsRepository.createList(
            sessionId: sessionId,
            name: name,
            description: description,
            completion: completion
        )
    }
}
