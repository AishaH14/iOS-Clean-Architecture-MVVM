//
//  DeleteListUseCase.swift
//  ExampleMVVM
//
//  Created by Aisha Hudasi on 16/01/1448 AH.
//
import Foundation

protocol DeleteListUseCase {
    func execute(
        listId: Int,
        sessionId: String,
        completion: @escaping (Result<Void, Error>) -> Void
    )
}

final class DefaultDeleteListUseCase: DeleteListUseCase {
    
    // MARK: - Properties
    private let listsRepository: ListsRepository
    
    // MARK: - Init
    init(listsRepository: ListsRepository) {
        self.listsRepository = listsRepository
    }
    
    // MARK: - Execute
    func execute(
        listId: Int,
        sessionId: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        listsRepository.deleteList(
            listId: listId,
            sessionId: sessionId,
            completion: completion
        )
    }
}
