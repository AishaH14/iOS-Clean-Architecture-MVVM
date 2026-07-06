//
//  FetchListMoviesUseCase.swift
//  ExampleMVVM
//
//  Created by Aisha Hudasi on 20/01/1448 AH.
//

import Foundation

protocol FetchListMoviesUseCase {
    func execute(
        listId: Int,
        completion: @escaping (Result<[Movie], Error>) -> Void
    )
}

final class DefaultFetchListMoviesUseCase: FetchListMoviesUseCase {

    private let listsRepository: ListsRepository

    init(listsRepository: ListsRepository) {
        self.listsRepository = listsRepository
    }

    func execute(
        listId: Int,
        completion: @escaping (Result<[Movie], Error>) -> Void
    ) {
        listsRepository.fetchListMovies(
            listId: listId,
            completion: completion
        )
    }
}
