//
//  FetchAccountDetailsUseCase.swift
//  ExampleMVVM
//
//  Created by Aisha Hudasi on 13/01/1448 AH.
//

import Foundation

protocol FetchAccountDetailsUseCase {
    @discardableResult
    func execute(
        sessionId: String,
        completion: @escaping (Result<Account, Error>) -> Void
    ) -> Cancellable?
}

final class DefaultFetchAccountDetailsUseCase: FetchAccountDetailsUseCase {
    
    private let userMediaRepository : UserMediaRepository
    
    init(userMediaRepository : UserMediaRepository) {
        self.userMediaRepository = userMediaRepository
    }
    
    @discardableResult
    func execute(
        sessionId: String,
        completion: @escaping (Result<Account, Error>) -> Void
    ) -> Cancellable? {
        userMediaRepository.fetchAccountDetails(
            sessionId: sessionId,
            completion: completion
        )
    }
}
