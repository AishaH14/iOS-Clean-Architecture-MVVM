//
//  FetchMoviesSectionUseCase.swift.swift
//  ExampleMVVM
//
//  Created by Aisha Hudasi on 19/02/1448 AH.
//

import Foundation

protocol FetchMoviesSectionUseCase {
    
    @discardableResult
    func execute(
        source: MoviesListSource,
        category: MediaCategory,
        page: Int,
        completion: @escaping (Result<MoviesPage, Error>) -> Void
    ) -> Cancellable?
}

final class DefaultFetchMoviesSectionUseCase: FetchMoviesSectionUseCase {
    
    private let moviesRepository: MoviesRepository
    
    init(moviesRepository: MoviesRepository) {
        self.moviesRepository = moviesRepository
    }
    
    @discardableResult
    func execute(
        source: MoviesListSource,
        category: MediaCategory,
        page: Int,
        completion: @escaping (Result<MoviesPage, Error>) -> Void
    ) -> Cancellable? {
        
        switch source {
        case .nowPlaying:
            return moviesRepository.fetchNowPlayingMovies(
                category: category,
                page: page,
                completion: completion
            )
            
        case .popular:
            return moviesRepository.fetchPopularMovies(
                category: category,
                page: page,
                completion: completion
            )
            
        case .topRated:
            return moviesRepository.fetchTopRatedMovies(
                category: category,
                page: page,
                completion: completion
            )
            
        case .upcoming:
            return moviesRepository.fetchUpcomingMovies(
                category: category,
                page: page,
                completion: completion
            )
            
        case .search:
            return nil
        }
    }
}
