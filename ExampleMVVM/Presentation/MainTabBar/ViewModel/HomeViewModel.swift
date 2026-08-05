//
//  HomeViewModel.swift
//  ExampleMVVM
//
//  Created by Aisha Hudasi on 19/11/1447 AH.
//

import Foundation

struct HomeMovieCellViewModel {
    let title: String?
    let rating: String
    let posterPath: String?
}

struct HomeSectionViewModel {
    let type: MoviesListSource
    let title: String
    let movies: [HomeMovieCellViewModel]
}

struct HomeViewModelActions {
    let showMovieDetails: (Movie) -> Void
    let showSeeAll: (MoviesListSource) -> Void
}

enum HomeViewModelLoading {
    case fullScreen
    case refresh
}

protocol HomeViewModelInput {
    func viewDidLoad()
    func didSelectMovie(sectionIndex: Int, movieIndex: Int)
    func didTapSeeAll(sectionIndex: Int)
    func didPullToRefresh()
}

protocol HomeViewModelOutput {
    var sections: Observable<[HomeSectionViewModel]> { get }
    var loading: Observable<HomeViewModelLoading?> { get }
    var error: Observable<String> { get }
    var screenTitle: String { get }
}

typealias HomeViewModel = HomeViewModelInput & HomeViewModelOutput

final class DefaultHomeViewModel: HomeViewModel {
    
    private let fetchHomeMoviesUseCase: FetchHomeMoviesUseCase
    private let actions: HomeViewModelActions?
    private let mainQueue: DispatchQueueType
    private var movieSections: [[Movie]] = []
    private var loadTask: Cancellable? { willSet { loadTask?.cancel() } }
    
    let sections: Observable<[HomeSectionViewModel]> = Observable([])
    let loading: Observable<HomeViewModelLoading?> = Observable(.none)
    let error: Observable<String> = Observable("")
    let screenTitle = NSLocalizedString("Home", comment: "")
    
    init(
        fetchHomeMoviesUseCase: FetchHomeMoviesUseCase,
        actions: HomeViewModelActions? = nil,
        mainQueue: DispatchQueueType = DispatchQueue.main
    ) {
        self.fetchHomeMoviesUseCase = fetchHomeMoviesUseCase
        self.actions = actions
        self.mainQueue = mainQueue
    }
    
    func viewDidLoad() {
        loadHomeMovies(loading: .fullScreen)
    }
    func didTapSeeAll(sectionIndex: Int) {
        guard sections.value.indices.contains(sectionIndex) else {
            return
        }

        let sectionType = sections.value[sectionIndex].type
        actions?.showSeeAll(sectionType)
    }
    func didPullToRefresh() {
        loadHomeMovies(loading: .refresh)
    }
    func didSelectMovie(sectionIndex: Int, movieIndex: Int) {
        guard movieSections.indices.contains(sectionIndex),
              movieSections[sectionIndex].indices.contains(movieIndex) else {
            return
        }
        
        let movie = movieSections[sectionIndex][movieIndex]
        actions?.showMovieDetails(movie)
    }
}

// MARK: - Private

private extension DefaultHomeViewModel {
    
    func loadHomeMovies(loading: HomeViewModelLoading) {
        self.loading.value = loading
        
        loadTask = fetchHomeMoviesUseCase.execute { [weak self] result in
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
           // self?.mainQueue.async {
                guard let self = self else { return }
                self.loading.value = .none
                
                switch result {
                case .success(let homeMovies):
                    
                    self.movieSections = [
                        homeMovies.nowPlaying,
                        homeMovies.popular,
                        homeMovies.topRated,
                        homeMovies.upcoming
                    ]
                    
                    self.sections.value = [
                        HomeSectionViewModel(
                            type: .nowPlaying,
                            title: NSLocalizedString("Now Playing", comment: ""),
                            movies: homeMovies.nowPlaying.map { HomeMovieCellViewModel(movie: $0) }
                        ),
                        HomeSectionViewModel(
                            type : .popular,
                            title: NSLocalizedString("Popular", comment: ""),
                            movies: homeMovies.popular.map { HomeMovieCellViewModel(movie: $0) }
                        ),
                        HomeSectionViewModel(
                            type: .topRated,
                            title: NSLocalizedString("Top Rated", comment: ""),
                            movies: homeMovies.topRated.map { HomeMovieCellViewModel(movie: $0) }
                        ),
                        HomeSectionViewModel(
                            type: .upcoming,
                            title: NSLocalizedString("Upcoming", comment: ""),
                            movies: homeMovies.upcoming.map { HomeMovieCellViewModel(movie: $0) }
                        )
                    ]
                    
                case .failure(let error):
                    self.handle(error: error)
                }
            }
        }
    }
    
    func handle(error: Error) {
        self.error.value = error.isInternetConnectionError ?
            NSLocalizedString("No internet connection", comment: "") :
            NSLocalizedString("Failed loading movies", comment: "")
    }
}
private extension HomeMovieCellViewModel {
    
    init(movie: Movie) {
        self.title = movie.title
        
        let ratingValue = movie.rating ?? 0
        self.rating = String(format: "%.1f", ratingValue)
        
        self.posterPath = movie.posterPath
    }
}
