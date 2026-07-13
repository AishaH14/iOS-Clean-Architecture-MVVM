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
    private let listsRepository: ListsRepository
    init(listsRepository: ListsRepository) {
        self.listsRepository = listsRepository
    }
    
    @discardableResult
    func execute(
        listId: Int,
        sessionId: String,
        movieId: Int,
        completion: @escaping (Result<Void, Error>) -> Void
    ) -> Cancellable? {
        listsRepository.removeMovieFromList(
            listId: listId,
            sessionId: sessionId,
            movieId: movieId,
            completion: completion
        )
    }
}
