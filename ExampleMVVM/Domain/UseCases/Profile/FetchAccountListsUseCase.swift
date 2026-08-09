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
    
    private let userMediaRepository: UserMediaRepository
    
    init(userMediaRepository: UserMediaRepository) {
        self.userMediaRepository = userMediaRepository
    }
    
    @discardableResult
    func execute(
        accountId: Int,
        sessionId: String,
        page: Int,
        completion: @escaping (Result<[MovieList], Error>) -> Void
    ) -> Cancellable? {
        userMediaRepository.fetchAccountLists(
            accountId: accountId,
            sessionId: sessionId,
            page: page,
            completion: completion
        )
    }
}
