//
//  FetchAccountDetailsUseCase.swift
//  ExampleMVVM
//
//  Created by Aisha Hudasi on 13/01/1448 AH.
//

import Foundation

protocol FetchAccountDetailsUseCase {
    func execute(
        sessionId: String,
        completion: @escaping (Result<Account, Error>) -> Void
    )
}

final class DefaultFetchAccountDetailsUseCase: FetchAccountDetailsUseCase {
    
    private let listsRepository: ListsRepository
    
    init(listsRepository: ListsRepository) {
        self.listsRepository = listsRepository
    }
    
    func execute(
        sessionId: String,
        completion: @escaping (Result<Account, Error>) -> Void
    ) {
        listsRepository.fetchAccountDetails(
            sessionId: sessionId,
            completion: completion
        )
    }
}
