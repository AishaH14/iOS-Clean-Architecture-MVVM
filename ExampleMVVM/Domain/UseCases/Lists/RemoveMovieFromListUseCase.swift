//
//  RemoveMovieFromListUseCase.swift
//  ExampleMVVM
//
//  Created by Aisha Hudasi on 21/01/1448 AH.
//

import Foundation

protocol RemoveMovieFromListUseCase {
    func execute(
        listId: Int,
        sessionId: String,
        movieId: Int,
        completion: @escaping (Result<Void, Error>) -> Void
    )
}

final class DefaultRemoveMovieFromListUseCase: RemoveMovieFromListUseCase {

    private let listsRepository: ListsRepository

    init(listsRepository: ListsRepository) {
        self.listsRepository = listsRepository
    }

    func execute(
        listId: Int,
        sessionId: String,
        movieId: Int,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        listsRepository.removeMovieFromList(
            listId: listId,
            sessionId: sessionId,
            movieId: movieId,
            completion: completion
        )
    }
}
