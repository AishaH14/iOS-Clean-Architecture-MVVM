//
//  FetchAccountListsUseCase.swift
//  ExampleMVVM
//
//  Created by Aisha Hudasi on 13/01/1448 AH.
//

import Foundation

protocol FetchAccountListsUseCase {
    @discardableResult
    func execute(
        accountId: Int,
        sessionId: String,
        page: Int,
        completion: @escaping (Result<[MovieList], Error>) -> Void
    ) -> Cancellable?
}

final class DefaultFetchAccountListsUseCase: FetchAccountListsUseCase {
    
    private let listsRepository: ListsRepository
    
    init(listsRepository: ListsRepository) {
        self.listsRepository = listsRepository
    }
    
    @discardableResult
    func execute(
        accountId: Int,
        sessionId: String,
        page: Int,
        completion: @escaping (Result<[MovieList], Error>) -> Void
    ) -> Cancellable? {
        listsRepository.fetchAccountLists(
            accountId: accountId,
            sessionId: sessionId,
            page: page,
            completion: completion
        )
    }
}
