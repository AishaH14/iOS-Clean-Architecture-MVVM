//
//  HomeViewModel.swift
//  ExampleMVVM
//
//  Created by Aisha Hudasi on 19/11/1447 AH.
//

import Foundation

struct HomeSectionViewModel {
    let title: String
    let movies: [Movie]
}

struct HomeViewModelActions {
    let showMovieDetails: (Movie) -> Void
}

protocol HomeViewModelInput {
    func viewDidLoad()
    func didSelectMovie(sectionIndex: Int, movieIndex: Int)
}

protocol HomeViewModelOutput {
    var sections: Observable<[HomeSectionViewModel]> { get }
    var loading: Observable<Bool> { get }
    var error: Observable<String> { get }
    var screenTitle: String { get }
}

typealias HomeViewModel = HomeViewModelInput & HomeViewModelOutput

final class DefaultHomeViewModel: HomeViewModel {
    
    private let fetchHomeMoviesUseCase: FetchHomeMoviesUseCase
    private let actions: HomeViewModelActions?
    private let mainQueue: DispatchQueueType
    
    private var loadTask: Cancellable? { willSet { loadTask?.cancel() } }
    
    let sections: Observable<[HomeSectionViewModel]> = Observable([])
    let loading: Observable<Bool> = Observable(false)
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
        loadHomeMovies()
    }
    
    func didSelectMovie(sectionIndex: Int, movieIndex: Int) {
        guard sections.value.indices.contains(sectionIndex),
              sections.value[sectionIndex].movies.indices.contains(movieIndex) else {
            return
        }
        
        let movie = sections.value[sectionIndex].movies[movieIndex]
        actions?.showMovieDetails(movie)
    }
}

// MARK: - Private

private extension DefaultHomeViewModel {
    
    func loadHomeMovies() {
        loading.value = true
        
        loadTask = fetchHomeMoviesUseCase.execute { [weak self] result in
            self?.mainQueue.async {
                self?.loading.value = false
                
                switch result {
                case .success(let homeMovies):
                    self?.sections.value = [
                        HomeSectionViewModel(title: "Now Playing", movies: homeMovies.nowPlaying),
                        HomeSectionViewModel(title: "Popular", movies: homeMovies.popular),
                        HomeSectionViewModel(title: "Top Rated", movies: homeMovies.topRated),
                        HomeSectionViewModel(title: "Upcoming", movies: homeMovies.upcoming)
                    ]
                    
                case .failure(let error):
                    self?.handle(error: error)
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
