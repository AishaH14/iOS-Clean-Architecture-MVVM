//
//  AddMovieToListUseCase.swift
//  ExampleMVVM
//
//  Created by Aisha Hudasi on 20/01/1448 AH.
//

import Foundation

protocol AddMovieToListUseCase {
    func execute(
        listId: Int,
        sessionId: String,
        movieId: Int,
        completion: @escaping (Result<Void, Error>) -> Void
    )
}

final class DefaultAddMovieToListUseCase: AddMovieToListUseCase {
    
    // MARK: - Properties
    private let listsRepository: ListsRepository
    
    // MARK: - Init
    init(listsRepository: ListsRepository) {
        self.listsRepository = listsRepository
    }
    
    // MARK: - Execute
    func execute(
        listId: Int,
        sessionId: String,
        movieId: Int,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        listsRepository.addMovieToList(
            listId: listId,
            sessionId: sessionId,
            movieId: movieId,
            completion: completion
        )
    }
}
