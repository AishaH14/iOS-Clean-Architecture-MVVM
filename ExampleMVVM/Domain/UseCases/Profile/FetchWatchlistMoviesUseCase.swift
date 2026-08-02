//
//  FetchWatchlistMoviesUseCase.swift
//  ExampleMVVM
//
//  Created by Aisha Hudasi on 07/02/1448 AH.
//
import Foundation

protocol FetchWatchlistMoviesUseCase {
    @discardableResult
    func execute(
        accountId: Int,
        sessionId: String,
        page: Int,
        completion: @escaping (Result<[Movie], Error>) -> Void
    ) -> Cancellable?
}

final class DefaultFetchWatchlistMoviesUseCase: FetchWatchlistMoviesUseCase {

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
        userMediaRepository.fetchWatchlistMovies(
            accountId: accountId,
            sessionId: sessionId,
            page: page,
            completion: completion
        )
    }
}
