//
//  MediaListViewModel.swift
//  ExampleMVVM
//
//  Created by Aisha Hudasi on 20/01/1448 AH.
//

import Foundation

enum MediaListSource {
    case list(MovieList)
    case favorites
    case watchlist
}

protocol MediaListViewModelInput {
    func viewDidLoad()
    func didLoadNextPage()
    func deleteMovies(_ movies: [Movie])
}

protocol MediaListViewModelOutput {
    var source: MediaListSource { get }
    var movies: Observable<[Movie]> { get }
    var error: Observable<String> { get }
    var title: String { get }
    var itemCount: Int { get }
}

typealias MediaListViewModel = MediaListViewModelInput & MediaListViewModelOutput

final class DefaultMediaListViewModel: MediaListViewModel {
    
    // MARK: - Output
    
    let source: MediaListSource
    let movies: Observable<[Movie]> = Observable([])
    let error: Observable<String> = Observable("")
    
    var title: String {
        switch source {
        case .list(let list):
            return list.name
            
        case .favorites:
            return NSLocalizedString("Favorites", comment: "")
            
        case .watchlist:
            return NSLocalizedString("Watchlist", comment: "")
        }
    }
    
    var itemCount: Int {
        return movies.value.count
    }
    
    // MARK: - Properties
    
    private let fetchListMoviesUseCase: FetchListMoviesUseCase
    private let fetchFavoriteMoviesUseCase: FetchFavoriteMoviesUseCase
    private let fetchWatchlistMoviesUseCase: FetchWatchlistMoviesUseCase
    private let fetchAccountDetailsUseCase: FetchAccountDetailsUseCase
    private let updateFavoriteUseCase: UpdateFavoriteUseCase
    private let updateWatchlistUseCase: UpdateWatchlistUseCase
    private let removeMovieFromListUseCase: RemoveMovieFromListUseCase
    private let authSessionStorage: AuthSessionStorage
    private let mainQueue: DispatchQueueType
    
    private var currentPage = 1
    private var isLoadingNextPage = false
    private var hasMorePages = true
    
    private var fetchListMoviesTask: Cancellable? {
        willSet { fetchListMoviesTask?.cancel() }
    }
    
    private var fetchAccountDetailsTask: Cancellable? {
        willSet { fetchAccountDetailsTask?.cancel() }
    }
    
    private var fetchFavoriteMoviesTask: Cancellable? {
        willSet { fetchFavoriteMoviesTask?.cancel() }
    }
    
    private var fetchWatchlistMoviesTask: Cancellable? {
        willSet { fetchWatchlistMoviesTask?.cancel() }
    }
    
    // MARK: - Init
    
    init(
        source: MediaListSource,
        fetchListMoviesUseCase: FetchListMoviesUseCase,
        fetchAccountDetailsUseCase: FetchAccountDetailsUseCase,
        fetchFavoriteMoviesUseCase: FetchFavoriteMoviesUseCase,
        fetchWatchlistMoviesUseCase: FetchWatchlistMoviesUseCase,
        authSessionStorage: AuthSessionStorage,
        updateFavoriteUseCase: UpdateFavoriteUseCase,
        updateWatchlistUseCase: UpdateWatchlistUseCase,
        removeMovieFromListUseCase: RemoveMovieFromListUseCase,
        mainQueue: DispatchQueueType = DispatchQueue.main
    ) {
        self.source = source
        self.fetchListMoviesUseCase = fetchListMoviesUseCase
        self.fetchAccountDetailsUseCase = fetchAccountDetailsUseCase
        self.fetchFavoriteMoviesUseCase = fetchFavoriteMoviesUseCase
        self.fetchWatchlistMoviesUseCase = fetchWatchlistMoviesUseCase
        self.authSessionStorage = authSessionStorage
        self.updateFavoriteUseCase = updateFavoriteUseCase
        self.updateWatchlistUseCase = updateWatchlistUseCase
        self.removeMovieFromListUseCase = removeMovieFromListUseCase
        self.mainQueue = mainQueue
    }
    
    // MARK: - Input
    
    func viewDidLoad() {
        currentPage = 1
        hasMorePages = true
        loadCurrentSourcePage()
    }
    
    func didLoadNextPage() {
        guard !isLoadingNextPage, hasMorePages else { return }
        loadCurrentSourcePage()
    }
    func deleteMovies(_ selectedMovies: [Movie]) {
        guard !selectedMovies.isEmpty else { return }
        
        guard let sessionId = authSessionStorage.getSessionId() else {
            error.value = NSLocalizedString(
                "Session not found",
                comment: ""
            )
            return
        }
        
        switch source {
        case .list(let list):
            deleteMoviesFromList(
                selectedMovies,
                listId: list.id,
                sessionId: sessionId
            )
            
        case .favorites:
            deleteMoviesFromFavorites(
                selectedMovies,
                sessionId: sessionId
            )
            
        case .watchlist:
            deleteMoviesFromWatchlist(
                selectedMovies,
                sessionId: sessionId
            )
        }
    }
        private func deleteMoviesFromList(
            _ selectedMovies: [Movie],
            listId: Int,
            sessionId: String
        ) {
            selectedMovies.forEach { [weak self] movie in
                guard let movieId = Int(movie.id) else { return }

                self?.removeMovieFromListUseCase.execute(
                    listId: listId,
                    sessionId: sessionId,
                    movieId: movieId
                ) { [weak self] result in
                    self?.handleDeleteResult(
                        result,
                        movieId: movie.id
                    )
                }
            }
        }
    
    private func deleteMoviesFromFavorites(
        _ selectedMovies: [Movie],
        sessionId: String
    ) {
        fetchAccountDetailsTask = fetchAccountDetailsUseCase.execute(
            sessionId: sessionId
        ) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let account):
                selectedMovies.forEach { movie in
                    guard let movieId = Int(movie.id) else { return }

                    self.updateFavoriteUseCase.execute(
                        accountId: account.id,
                        sessionId: sessionId,
                        movieId: movieId,
                        favorite: false
                    ) { [weak self] result in
                        self?.handleDeleteResult(
                            result,
                            movieId: movie.id
                        )
                    }
                }

            case .failure(let error):
                self.mainQueue.async {
                    self.error.value = error.localizedDescription
                }
            }
        }
    }
    private func deleteMoviesFromWatchlist(
        _ selectedMovies: [Movie],
        sessionId: String
    ) {
        fetchAccountDetailsTask = fetchAccountDetailsUseCase.execute(
            sessionId: sessionId
        ) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let account):
                selectedMovies.forEach { movie in
                    guard let movieId = Int(movie.id) else { return }

                    self.updateWatchlistUseCase.execute(
                        accountId: account.id,
                        sessionId: sessionId,
                        movieId: movieId,
                        watchlist: false
                    ) { [weak self] result in
                        self?.handleDeleteResult(
                            result,
                            movieId: movie.id
                        )
                    }
                }

            case .failure(let error):
                self.mainQueue.async {
                    self.error.value = error.localizedDescription
                }
            }
        }
    }
    private func handleDeleteResult(
        _ result: Result<Void, Error>,
        movieId: String
    ) {
        mainQueue.async { [weak self] in
            guard let self = self else { return }

            switch result {
            case .success:
                self.movies.value.removeAll {
                    $0.id == movieId
                }

            case .failure(let error):
                self.error.value = error.localizedDescription
            }
        }
    }

    // MARK: - Master Loader Logic

    private func loadCurrentSourcePage() {
        switch source {
        case .list(let list):
            loadListMovies(listId: list.id)

        case .favorites:
            loadAccountBasedMedia { [weak self] accountId, sessionId, page in
                self?.fetchFavoriteMovies(accountId: accountId, sessionId: sessionId, page: page)
            }

        case .watchlist:
            loadAccountBasedMedia { [weak self] accountId, sessionId, page in
                self?.fetchWatchlistMovies(accountId: accountId, sessionId: sessionId, page: page)
            }
        }
    }

    // MARK: - Custom List

    private func loadListMovies(listId: Int) {
        isLoadingNextPage = true
        fetchListMoviesTask = fetchListMoviesUseCase.execute(listId: listId) { [weak self] result in
            self?.mainQueue.async {
                guard let self = self else { return }
                self.isLoadingNextPage = false
                
                switch result {
                case .success(let newMovies):
                    self.handleMoviesResult(newMovies)

                case .failure:
                    self.error.value = NSLocalizedString("Failed to fetch list movies", comment: "")
                }
            }
        }
    }

    // MARK: - Helper For Account Details (Eliminates Duplication)

    private func loadAccountBasedMedia(action: @escaping (_ accountId: Int, _ sessionId: String, _ page: Int) -> Void) {
        guard let sessionId = authSessionStorage.getSessionId() else {
            error.value = NSLocalizedString("Session not found", comment: "")
            return
        }

        isLoadingNextPage = true

        fetchAccountDetailsTask = fetchAccountDetailsUseCase.execute(sessionId: sessionId) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let account):
                action(account.id, sessionId, self.currentPage)

            case .failure(let error):
                self.mainQueue.async {
                    self.isLoadingNextPage = false
                    self.error.value = error.localizedDescription
                }
            }
        }
    }

    // MARK: - Favorites & Watchlist Fetchers

    private func fetchFavoriteMovies(accountId: Int, sessionId: String, page: Int) {
        fetchFavoriteMoviesTask = fetchFavoriteMoviesUseCase.execute(
            accountId: accountId,
            sessionId: sessionId,
            page: page
        ) { [weak self] result in
            self?.processFetchResult(result)
        }
    }

    private func fetchWatchlistMovies(accountId: Int, sessionId: String, page: Int) {
        fetchWatchlistMoviesTask = fetchWatchlistMoviesUseCase.execute(
            accountId: accountId,
            sessionId: sessionId,
            page: page
        ) { [weak self] result in
            self?.processFetchResult(result)
        }
    }

    // MARK: - Result Processors (Clean DRY Principles)

    private func processFetchResult(_ result: Result<[Movie], Error>) {
        mainQueue.async { [weak self] in
            guard let self = self else { return }
            self.isLoadingNextPage = false

            switch result {
            case .success(let newMovies):
                self.handleMoviesResult(newMovies)

            case .failure(let error):
                self.error.value = error.localizedDescription
            }
        }
    }

    private func handleMoviesResult(_ newMovies: [Movie]) {
        guard !newMovies.isEmpty else {
            hasMorePages = false
            return
        }

        if currentPage == 1 {
            movies.value = newMovies
        } else {
            movies.value.append(contentsOf: newMovies)
        }

        currentPage += 1
    }
}
