import Foundation

struct MovieDetailsViewModelActions {
    let showLists: (
        _ movieId: Int,
        _ didAddMovie: @escaping (_ listId: Int) -> Void
    ) -> Void
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
    private let removeMovieFromListUseCase: RemoveMovieFromListUseCase
    private let authSessionStorage: AuthSessionStorage
    private let fetchAccountDetailsUseCase: FetchAccountDetailsUseCase
    private let fetchAccountListsUseCase: FetchAccountListsUseCase
    private let fetchListMoviesUseCase: FetchListMoviesUseCase
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
        removeMovieFromListUseCase: RemoveMovieFromListUseCase,
        authSessionStorage: AuthSessionStorage,
        fetchAccountDetailsUseCase: FetchAccountDetailsUseCase,
        fetchAccountListsUseCase: FetchAccountListsUseCase,
        fetchListMoviesUseCase: FetchListMoviesUseCase,
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
        self.removeMovieFromListUseCase = removeMovieFromListUseCase
        self.authSessionStorage = authSessionStorage
        self.fetchAccountDetailsUseCase = fetchAccountDetailsUseCase
        self.fetchAccountListsUseCase = fetchAccountListsUseCase
        self.fetchListMoviesUseCase = fetchListMoviesUseCase
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
        checkIfMovieIsAlreadyAdded()
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
        movieDetailsRepository.toggleFavorite(movieId: movieId)
        isFavorite.value = movieDetailsRepository.isFavorite(movieId: movieId)
    }

    func toggleWatchlist() {
        movieDetailsRepository.toggleWatchlist(movieId: movieId)
        isInWatchlist.value = movieDetailsRepository.isInWatchlist(movieId: movieId)
    }
    func addToList() {
        guard let movieId = Int(movieId) else { return }
        if isAddedToList.value {
            removeFromList(movieId: movieId)
            return
        }
        actions.showLists(movieId) { [weak self] listId in
            self?.addedListId = listId
            self?.isAddedToList.value = true
        }
    }
    private func removeFromList(movieId: Int) {
        guard let listId = addedListId else { return }

        guard let sessionId = authSessionStorage.getSessionId() else {
            return
        }

        removeMovieFromListUseCase.execute(
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
    private func checkIfMovieIsAlreadyAdded() {
        guard let sessionId = authSessionStorage.getSessionId() else { return }
        guard let currentMovieId = Int(movieId) else { return }

        fetchAccountDetailsUseCase.execute(
            sessionId: sessionId
        ) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let account):
                self.fetchAccountListsUseCase.execute(
                    accountId: account.id,
                    sessionId: sessionId,
                    page: 1
                ) { [weak self] result in
                    guard let self = self else { return }

                    guard case let .success(lists) = result else { return }

                    for list in lists {
                        self.fetchListMoviesUseCase.execute(
                            listId: list.id
                        ) { [weak self] result in
                            guard let self = self else { return }

                            guard case let .success(movies) = result else { return }

                            let containsMovie = movies.contains {
                                Int($0.id) == currentMovieId
                            }

                            guard containsMovie else { return }

                            self.mainQueue.async {
                                self.addedListId = list.id
                                self.isAddedToList.value = true
                            }
                        }
                    }
                }

            case .failure:
                break
            }
        }
    }
    }

