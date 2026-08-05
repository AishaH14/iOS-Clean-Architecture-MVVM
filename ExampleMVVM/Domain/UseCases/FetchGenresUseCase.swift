//
//  FetchGenresUseCase.swift
//  ExampleMVVM
//
//  Created by Azhar Ghurab on 22/12/1447 AH.
//

import Foundation

protocol FetchGenresUseCase {
    
    @discardableResult
    func execute(
        category: MediaCategory,
        completion: @escaping (Result<[Genre], Error>) -> Void
    ) -> Cancellable?
}
final class DefaultFetchGenresUseCase: FetchGenresUseCase {
    
    private let genresRepository: GenresRepository
    
    init(genresRepository: GenresRepository) {
        self.genresRepository = genresRepository
    }
    
    @discardableResult
    func execute(
        category: MediaCategory,
        completion: @escaping (Result<[Genre], Error>) -> Void
    ) -> Cancellable? {
        switch category {
                case .movies:
                    return genresRepository.fetchMovieGenres(
                        completion: completion
                    )
                    
                case .tvShows:
                    return genresRepository.fetchTVGenres(
                        completion: completion
                    )
                }
            }
        }
       
        
