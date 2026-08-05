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
        page: Int,
        completion: @escaping (Result<MoviesPage, Error>) -> Void
    ) -> Cancellable? {
        
        switch source {
        case .nowPlaying:
            return moviesRepository.fetchNowPlayingMovies(
                page: page,
                completion: completion
            )
            
        case .popular:
            return moviesRepository.fetchPopularMovies(
                page: page,
                completion: completion
            )
            
        case .topRated:
            return moviesRepository.fetchTopRatedMovies(
                page: page,
                completion: completion
            )
            
        case .upcoming:
            return moviesRepository.fetchUpcomingMovies(
                page: page,
                completion: completion
            )
            
        case .search:
            return nil
        }
    }
}
