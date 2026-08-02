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
    
    private let userMediaRepository: UserMediaRepository
    
    init(userMediaRepository: UserMediaRepository) {
        self.userMediaRepository = userMediaRepository
    }
    
    @discardableResult
    func execute(
        listId: Int,
        completion: @escaping (Result<[Movie], Error>) -> Void
    ) -> Cancellable? {
        userMediaRepository.fetchListMovies(
            listId: listId,
            completion: completion
        )
    }
}
