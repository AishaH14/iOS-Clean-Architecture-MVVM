//
//  RemoveMovieFromListUseCase.swift
//  ExampleMVVM
//
//  Created by Aisha Hudasi on 21/01/1448 AH.
//

import Foundation

protocol RemoveMovieFromListUseCase {
    @discardableResult
    func execute(
        listId: Int,
        sessionId: String,
        movieId: Int,
        completion: @escaping (Result<Void, Error>) -> Void
    ) -> Cancellable?
}

final class DefaultRemoveMovieFromListUseCase: RemoveMovieFromListUseCase {
    private let userMediaRepository: UserMediaRepository
    init(userMediaRepository: UserMediaRepository) {
        self.userMediaRepository = userMediaRepository
    }
    
    @discardableResult
    func execute(
        listId: Int,
        sessionId: String,
        movieId: Int,
        completion: @escaping (Result<Void, Error>) -> Void
    ) -> Cancellable? {
        userMediaRepository.removeMovieFromList(
            listId: listId,
            sessionId: sessionId,
            movieId: movieId,
            completion: completion
        )
    }
}
