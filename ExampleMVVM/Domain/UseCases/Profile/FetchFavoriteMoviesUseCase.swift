//
//  FetchFavoriteMoviesUseCase.swift
//  ExampleMVVM
//
//  Created by Aisha Hudasi on 07/02/1448 AH.
//

import Foundation

protocol FetchFavoriteMoviesUseCase {
    @discardableResult
    func execute(
        accountId: Int,
        sessionId: String,
        page: Int,
        completion: @escaping (Result<[Movie], Error>) -> Void
    ) -> Cancellable?
}

final class DefaultFetchFavoriteMoviesUseCase: FetchFavoriteMoviesUseCase {

    private let userMediaRepository: UserMediaRepository
    init(userMediaRepository: UserMediaRepository) {
        self.userMediaRepository = userMediaRepository
    }

    @discardableResult
    func execute(
        accountId: Int,
        sessionId: String,
        page: Int,
        completion: @escaping (Result<[Movie], Error>) -> Void
    ) -> Cancellable? {
        userMediaRepository.fetchFavoriteMovies(
            accountId: accountId,
            sessionId: sessionId,
            page: page,
            completion: completion
           
        )
    }
}
