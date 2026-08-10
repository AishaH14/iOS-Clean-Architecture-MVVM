import Foundation

protocol MoviesRepository {
    @discardableResult
    func fetchMoviesList(
        query: MovieQuery,
        category: MediaCategory,
        page: Int,
        cached: @escaping (MoviesPage) -> Void,
        completion: @escaping (Result<MoviesPage, Error>) -> Void
    ) -> Cancellable?


    func fetchNowPlayingMovies(
        category: MediaCategory,
        page: Int,
        completion: @escaping (Result<MoviesPage, Error>) -> Void
    ) -> Cancellable?

    func fetchPopularMovies(
        category: MediaCategory,
        page: Int,
        completion: @escaping (Result<MoviesPage, Error>) -> Void
    ) -> Cancellable?

    func fetchTopRatedMovies(
        category: MediaCategory,
        page: Int,
        completion: @escaping (Result<MoviesPage, Error>) -> Void
    ) -> Cancellable?

    func fetchUpcomingMovies(
        category: MediaCategory,
        page: Int,
        completion: @escaping (Result<MoviesPage, Error>) -> Void
           ) -> Cancellable?
    
}
