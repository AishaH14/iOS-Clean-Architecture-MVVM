import Foundation

struct MovieDetailsUseCases {
    let removeMovieFromListUseCase: RemoveMovieFromListUseCase
    let fetchAccountDetailsUseCase: FetchAccountDetailsUseCase
    let fetchAccountListsUseCase: FetchAccountListsUseCase
    let fetchListMoviesUseCase: FetchListMoviesUseCase
    let updateFavoriteUseCase: UpdateFavoriteUseCase
    let updateWatchlistUseCase: UpdateWatchlistUseCase
    let fetchFavoriteMoviesUseCase: FetchFavoriteMoviesUseCase
    let fetchWatchlistMoviesUseCase: FetchWatchlistMoviesUseCase
}
struct MovieDetailsViewModelActions {
    let showLists: (
        _ movieId: Int,
        _ currentListId: Int?,
        _ didAddMovie: @escaping (_ listId: Int) -> Void
    ) -> Void
    
    let showAuthorization: () -> Void
}
protocol MovieDetailsViewModelInput {
    func updatePosterImage(width: Int)
    func toggleFavorite()
    func toggleWatchlist()
    func addToList()
    func viewDidLoad()
}

protocol MovieDetailsViewModelOutput {
    var title: String { get }
    var posterImage: Observable<Data?> { get }
    var isPosterImageHidden: Bool { get }
    var rating: String { get }
    var isFavorite: Observable<Bool> { get }
    var isInWatchlist: Observable<Bool> { get }
    var isAddedToList: Observable<Bool> { get }
    var overview: String { get }
}

protocol MovieDetailsViewModel: MovieDetailsViewModelInput, MovieDetailsViewModelOutput { }

final class DefaultMovieDetailsViewModel: MovieDetailsViewModel {
    
    private let posterImagePath: String?
    private let posterImagesRepository: PosterImagesRepository
    private var imageLoadTask: Cancellable? { willSet { imageLoadTask?.cancel() } }
    private let mainQueue: DispatchQueueType
    
    private let movieId: String
    private let movieDetailsRepository : MovieDetailsRepository
    private(set) var isFavorite: Observable<Bool>
    private(set) var isInWatchlist: Observable<Bool>
    private(set) var isAddedToList: Observable<Bool> = Observable(false)
    private var addedListId: Int?
    private let actions: MovieDetailsViewModelActions
    private let authSessionStorage: AuthSessionStorage
    private let movieDetailsUseCases: MovieDetailsUseCases
    private var updateFavoriteTask: Cancellable?
    private var updateWatchlistTask: Cancellable?
    private var favoriteAccountDetailsTask: Cancellable?
    private var watchlistAccountDetailsTask: Cancellable?
    private var fetchFavoriteTask: Cancellable? {
        willSet {
            fetchFavoriteTask?.cancel()
        }
    }
    private var fetchWatchlistTask: Cancellable? {
        willSet {
            fetchWatchlistTask?.cancel()
        }
    }
    private var removeMovieFromListTask: Cancellable? {
        willSet {
            removeMovieFromListTask?.cancel()
        }
    }

    private var fetchAccountDetailsTask: Cancellable? {
        willSet {
            fetchAccountDetailsTask?.cancel()
        }
    }

    private var fetchAccountListsTask: Cancellable? {
        willSet {
            fetchAccountListsTask?.cancel()
        }
    }
    private var fetchListMoviesTasks: [Cancellable] = []
    // MARK: - OUTPUT
    let title: String
    let posterImage: Observable<Data?> = Observable(nil)
    let isPosterImageHidden: Bool
    let rating: String
    let overview: String
    
    init(
        movie: Movie,
        posterImagesRepository: PosterImagesRepository,
        movieDetailsRepository: MovieDetailsRepository,
        authSessionStorage: AuthSessionStorage,
        movieDetailsUseCases: MovieDetailsUseCases,
        actions: MovieDetailsViewModelActions,
        mainQueue: DispatchQueueType = DispatchQueue.main
        
    ) {
        self.movieId = movie.id
        self.title = movie.title ?? ""
        self.overview = movie.overview ?? ""
        self.posterImagePath = movie.posterPath
        self.isPosterImageHidden = movie.posterPath == nil
        self.posterImagesRepository = posterImagesRepository
        self.movieDetailsRepository = movieDetailsRepository
        self.authSessionStorage = authSessionStorage
        self.movieDetailsUseCases = movieDetailsUseCases
        self.mainQueue = mainQueue
        self.rating = String(format: "%.1f", movie.rating ?? 0)
        self.isFavorite = Observable(movieDetailsRepository.isFavorite(movieId: movieId))
        self.isInWatchlist = Observable(movieDetailsRepository.isInWatchlist(movieId: movieId))
        self.actions = actions
    }
}

// MARK: - INPUT. View event methods
extension DefaultMovieDetailsViewModel {
    
    func viewDidLoad() {
        fetchMovieStatusInListsAndFavorites()
    }
    func updatePosterImage(width: Int) {
        guard let posterImagePath = posterImagePath else { return }
        
        imageLoadTask = posterImagesRepository.fetchImage(
            with: posterImagePath,
            width: width
        ) { [weak self] result in
            self?.mainQueue.async {
                guard self?.posterImagePath == posterImagePath else { return }
                switch result {
                case .success(let data):
                    self?.posterImage.value = data
                case .failure: break
                }
                self?.imageLoadTask = nil
            }
        }
    }
    func toggleFavorite() {
        guard let sessionId = authSessionStorage.getSessionId(),
              let currentMovieId = Int(movieId) else {
            return
        }
        
        let newFavoriteValue = !isFavorite.value
        
        favoriteAccountDetailsTask = movieDetailsUseCases.fetchAccountDetailsUseCase.execute(
            sessionId: sessionId
        ) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let account):
                self.updateFavoriteTask = self.movieDetailsUseCases.updateFavoriteUseCase.execute(
                    accountId: account.id,
                    sessionId: sessionId,
                    movieId: currentMovieId,
                    favorite: newFavoriteValue
                ) { [weak self] result in
                    self?.mainQueue.async {
                        guard let self = self else { return }
                        
                        switch result {
                        case .success:
                            self.movieDetailsRepository.toggleFavorite(
                                movieId: self.movieId
                            )
                            self.isFavorite.value = newFavoriteValue
                            
                        case .failure:
                            break
                        }
                    }
                }
                
            case .failure:
                break
            }
        }
    }
    
    func toggleWatchlist() {
        guard let sessionId = authSessionStorage.getSessionId(),
              let currentMovieId = Int(movieId) else {
            return
        }
        
        let newWatchlistValue = !isInWatchlist.value
        
        watchlistAccountDetailsTask = movieDetailsUseCases.fetchAccountDetailsUseCase.execute(
            sessionId: sessionId
        ) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let account):
                self.updateWatchlistTask = self.movieDetailsUseCases.updateWatchlistUseCase.execute(
                    accountId: account.id,
                    sessionId: sessionId,
                    movieId: currentMovieId,
                    watchlist: newWatchlistValue
                ) { [weak self] result in
                    self?.mainQueue.async {
                        guard let self = self else { return }
                        
                        switch result {
                        case .success:
                            self.movieDetailsRepository.toggleWatchlist(
                                movieId: self.movieId
                            )
                            self.isInWatchlist.value = newWatchlistValue
                            
                        case .failure:
                            break
                        }
                    }
                }
                
            case .failure:
                break
            }
        }
    }
    func addToList() {
        guard let movieId = Int(movieId) else { return }
        
        actions.showLists(
            movieId,
            addedListId
        ) { [weak self] listId in
            guard let self = self else { return }
            
            if self.addedListId == listId {
                return
            }
            
            self.addedListId = listId
            self.isAddedToList.value = true
        }
    }
    private func removeFromList(movieId: Int) {
        guard let listId = addedListId else { return }
        
        guard let sessionId = authSessionStorage.getSessionId() else {
            return
        }
        
        removeMovieFromListTask = movieDetailsUseCases.removeMovieFromListUseCase.execute(
            listId: listId,
            sessionId: sessionId,
            movieId: movieId
        ) { [weak self] result in
            self?.mainQueue.async {
                switch result {
                case .success:
                    self?.addedListId = nil
                    self?.isAddedToList.value = false
                    
                case .failure:
                    break
                }
            }
        }
        
    }
    private func fetchUserLists(accountId: Int, sessionId: String) {
        guard let currentMovieId = Int(movieId) else { return }
        
        fetchAccountListsTask = movieDetailsUseCases.fetchAccountListsUseCase.execute(
            accountId: accountId,
            sessionId: sessionId,
            page: 1
        ) { [weak self] result in
            guard let self = self, case let .success(lists) = result else { return }
            
            self.fetchListMoviesTasks.forEach { $0.cancel() }
            self.fetchListMoviesTasks.removeAll()
            
            for list in lists {
                if let task = self.movieDetailsUseCases.fetchListMoviesUseCase.execute(
                    listId: list.id,
                    completion: { [weak self] result in
                        guard let self = self, case let .success(movies) = result else { return }
                        let containsMovie = movies.contains { Int($0.id) == currentMovieId }
                        guard containsMovie else { return }
                        
                        self.mainQueue.async {
                            self.addedListId = list.id
                            self.isAddedToList.value = true
                        }
                    }
                ) {
                    self.fetchListMoviesTasks.append(task)
                }
            }
        }
    }

    private func fetchFavoriteAndWatchlist(accountId: Int, sessionId: String) {
        fetchFavoriteTask = movieDetailsUseCases.fetchFavoriteMoviesUseCase.execute(
            accountId: accountId,
            sessionId: sessionId,
            page: 1
        ) { [weak self] result in
            guard let self = self, case let .success(favoriteMovies) = result else { return }
            let isFav = favoriteMovies.contains { $0.id == self.movieId }
            self.mainQueue.async {
                self.isFavorite.value = isFav
            }
        }
        
        fetchWatchlistTask = movieDetailsUseCases.fetchWatchlistMoviesUseCase.execute(
            accountId: accountId,
            sessionId: sessionId,
            page: 1
        ) { [weak self] result in
            guard let self = self, case let .success(watchlistMovies) = result else { return }
            let inWatchlist = watchlistMovies.contains { $0.id == self.movieId }
            self.mainQueue.async {
                self.isInWatchlist.value = inWatchlist
            }
        }
    }
    private func fetchMovieStatusInListsAndFavorites() {
        guard let sessionId = authSessionStorage.getSessionId() else { return }
        
        fetchAccountDetailsTask = movieDetailsUseCases.fetchAccountDetailsUseCase.execute(
            sessionId: sessionId
        ) { [weak self] result in
            guard let self = self, case let .success(account) = result else { return }
            self.fetchUserLists(accountId: account.id, sessionId: sessionId)
            
            self.fetchFavoriteAndWatchlist(accountId: account.id, sessionId: sessionId)
        }
    }
}
