//
//  DeleteListUseCase.swift
//  ExampleMVVM
//
//  Created by Aisha Hudasi on 16/01/1448 AH.
//
import Foundation

protocol DeleteListUseCase {
    @discardableResult
    func execute(
        listId: Int,
        sessionId: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) -> Cancellable?
}

final class DefaultDeleteListUseCase: DeleteListUseCase {
    
    private let listsRepository: ListsRepository
    
    init(listsRepository: ListsRepository) {
        self.listsRepository = listsRepository
    }
    
    @discardableResult
    func execute(
        listId: Int,
        sessionId: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) -> Cancellable? {
        listsRepository.deleteList(
            listId: listId,
            sessionId: sessionId,
            completion: completion
        )
    }
}
