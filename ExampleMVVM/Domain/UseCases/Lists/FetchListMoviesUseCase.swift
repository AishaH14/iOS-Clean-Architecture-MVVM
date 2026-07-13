//
//  FetchListMoviesUseCase.swift
//  ExampleMVVM
//
//  Created by Aisha Hudasi on 20/01/1448 AH.
//

import Foundation

protocol FetchListMoviesUseCase {
    @discardableResult
    func execute(
        listId: Int,
        completion: @escaping (Result<[Movie], Error>) -> Void
    ) -> Cancellable?
}

final class DefaultFetchListMoviesUseCase: FetchListMoviesUseCase {
    
    private let listsRepository: ListsRepository
    
    init(listsRepository: ListsRepository) {
        self.listsRepository = listsRepository
    }
    
    @discardableResult
    func execute(
        listId: Int,
        completion: @escaping (Result<[Movie], Error>) -> Void
    ) -> Cancellable? {
        listsRepository.fetchListMovies(
            listId: listId,
            completion: completion
        )
    }
}
