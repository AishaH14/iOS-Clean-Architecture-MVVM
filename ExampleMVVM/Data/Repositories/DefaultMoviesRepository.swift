// **Note**: DTOs structs are mapped into Domains here, and Repository protocols does not contain DTOs

import Foundation

final class DefaultMoviesRepository {

    private let dataTransferService: DataTransferService
    private let cache: MoviesResponseStorage
    private let backgroundQueue: DataTransferDispatchQueue

    init(
        dataTransferService: DataTransferService,
        cache: MoviesResponseStorage,
        backgroundQueue: DataTransferDispatchQueue = DispatchQueue.global(qos: .userInitiated)
    ) {
        self.dataTransferService = dataTransferService
        self.cache = cache
        self.backgroundQueue = backgroundQueue
    }
}

extension DefaultMoviesRepository: MoviesRepository {
    
    func fetchMoviesList(
        query: MovieQuery,
        category: MediaCategory,
        page: Int,
        cached: @escaping (MoviesPage) -> Void,
        completion: @escaping (Result<MoviesPage, Error>) -> Void
    ) -> Cancellable? {
        
        let requestDTO = MoviesRequestDTO(query: query.query, page: page)
        let task = RepositoryTask()
        
        cache.getResponse(for: requestDTO) { [weak self, backgroundQueue] result in
            
            if case let .success(responseDTO?) = result {
                cached(responseDTO.toDomain())
            }
            
            guard !task.isCancelled else { return }
            
            let endpoint = MoviesEndpoints.searchMedia(category: category, with: requestDTO)
            task.networkTask = self?.dataTransferService.request(
                with: endpoint,
                on: backgroundQueue
            ) { result in
                switch result {
                case .success(let responseDTO):
                    self?.cache.save(response: responseDTO, for: requestDTO)
                    completion(.success(responseDTO.toDomain()))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
        
        return task
    }
    
    func fetchNowPlayingMovies(
        category: MediaCategory,
        page: Int,
        completion: @escaping (Result<MoviesPage, Error>) -> Void
    ) -> Cancellable? {
        let requestDTO = MoviesListRequestDTO(page: page)
        let endpoint = category == .movies
            ? MoviesEndpoints.getNowPlayingMovies(with: requestDTO)
            : MoviesEndpoints.getAiringTodayTV(with: requestDTO)
        return fetchMoviesList(endpoint: endpoint, completion: completion)
    }
    
    func fetchPopularMovies(
        category: MediaCategory,
        page: Int,
        completion: @escaping (Result<MoviesPage, Error>) -> Void
    ) -> Cancellable? {
        let requestDTO = MoviesListRequestDTO(page: page)
        let endpoint = category == .movies
            ? MoviesEndpoints.getPopularMovies(with: requestDTO)
            : MoviesEndpoints.getPopularTV(with: requestDTO)
        return fetchMoviesList(endpoint: endpoint, completion: completion)
    }
    
    func fetchTopRatedMovies(
        category: MediaCategory,
        page: Int,
        completion: @escaping (Result<MoviesPage, Error>) -> Void
    ) -> Cancellable? {
        let requestDTO = MoviesListRequestDTO(page: page)
        let endpoint = category == .movies
            ? MoviesEndpoints.getTopRatedMovies(with: requestDTO)
            : MoviesEndpoints.getTopRatedTV(with: requestDTO)
        return fetchMoviesList(endpoint: endpoint, completion: completion)
    }
    
    func fetchUpcomingMovies(
        category: MediaCategory,
        page: Int,
        completion: @escaping (Result<MoviesPage, Error>) -> Void
    ) -> Cancellable? {
        let requestDTO = MoviesListRequestDTO(page: page)
        let endpoint = category == .movies
            ? MoviesEndpoints.getUpcomingMovies(with: requestDTO)
            : MoviesEndpoints.getOnTheAirTV(with: requestDTO)
        return fetchMoviesList(endpoint: endpoint, completion: completion)
    }
}

// MARK: - Private

private extension DefaultMoviesRepository {
    
    func fetchMoviesList(
        endpoint: Endpoint<MoviesResponseDTO>,
        completion: @escaping (Result<MoviesPage, Error>) -> Void
    ) -> Cancellable? {
        let task = RepositoryTask()
        
        task.networkTask = dataTransferService.request(
            with: endpoint,
            on: backgroundQueue
        ) { result in
            switch result {
            case .success(let responseDTO):
                completion(.success(responseDTO.toDomain()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
        return task
    }
}
