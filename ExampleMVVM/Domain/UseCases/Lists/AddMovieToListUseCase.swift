//
//  AddMovieToListUseCase.swift
//  ExampleMVVM
//
//  Created by Aisha Hudasi on 20/01/1448 AH.
//

import Foundation

protocol AddMovieToListUseCase {
    @discardableResult
    func execute(
        listId: Int,
        sessionId: String,
        movieId: Int,
        completion: @escaping (Result<Void, Error>) -> Void
    ) -> Cancellable?
}

final class DefaultAddMovieToListUseCase: AddMovieToListUseCase {
    
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
        listsRepository.addMovieToList(
            listId: listId,
            sessionId: sessionId,
            movieId: movieId,
            completion: completion
        )
    }
}
