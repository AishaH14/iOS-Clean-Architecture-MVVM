//
//  UpdateWatchlistUseCase.swift
//  ExampleMVVM
//
//  Created by Aisha Hudasi on 08/02/1448 AH.
//

import Foundation

protocol UpdateWatchlistUseCase {
    @discardableResult
    func execute(
        accountId: Int,
        sessionId: String,
        movieId: Int,
        watchlist: Bool,
        completion: @escaping (Result<Void, Error>) -> Void
    ) -> Cancellable?
}

final class DefaultUpdateWatchlistUseCase: UpdateWatchlistUseCase {

    private let userMediaRepository: UserMediaRepository

    init(userMediaRepository: UserMediaRepository) {
        self.userMediaRepository = userMediaRepository
    }
    @discardableResult
    func execute(
        accountId: Int,
        sessionId: String,
        movieId: Int,
        watchlist: Bool,
        completion: @escaping (Result<Void, Error>) -> Void
    ) -> Cancellable? {
        userMediaRepository.updateWatchlist(
            accountId: accountId,
            sessionId: sessionId,
            movieId: movieId,
            watchlist: watchlist,
            completion: completion
        )
    }
}
