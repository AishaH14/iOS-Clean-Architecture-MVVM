//
//  UpdateFavoriteUseCase.swift
//  ExampleMVVM
//
//  Created by Aisha Hudasi on 08/02/1448 AH.
//

import Foundation

protocol UpdateFavoriteUseCase {
    @discardableResult
    func execute(
        accountId: Int,
        sessionId: String,
        movieId: Int,
        favorite: Bool,
        completion: @escaping (Result<Void, Error>) -> Void
    ) -> Cancellable?
}

final class DefaultUpdateFavoriteUseCase: UpdateFavoriteUseCase {

    private let userMediaRepository: UserMediaRepository

    init(userMediaRepository: UserMediaRepository) {
        self.userMediaRepository = userMediaRepository
    }
    @discardableResult
    func execute(
        accountId: Int,
        sessionId: String,
        movieId: Int,
        favorite: Bool,
        completion: @escaping (Result<Void, Error>) -> Void
    ) -> Cancellable? {
        userMediaRepository.updateFavorite(
            accountId: accountId,
            sessionId: sessionId,
            movieId: movieId,
            favorite: favorite,
            completion: completion
        )
    }
}
