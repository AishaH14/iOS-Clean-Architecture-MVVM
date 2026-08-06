import Foundation

struct MoviesListViewModelActions {
    /// Note: if you would need to edit movie inside Details screen and update this Movies List screen with updated movie then you would need this closure:
    /// showMovieDetails: (Movie, @escaping (_ updated: Movie) -> Void) -> Void
    let showMovieDetails: (Movie) -> Void
    let showMovieQueriesSuggestions: (@escaping (_ didSelect: MovieQuery) -> Void) -> Void
    let closeMovieQueriesSuggestions: () -> Void
}

enum MoviesListViewModelLoading {
    case fullScreen
    case nextPage
}

protocol MoviesListViewModelInput {
    func viewDidLoad()
    func didLoadNextPage()
    func didSearch(query: String)
    func didCancelSearch()
    func showQueriesSuggestions()
    func closeQueriesSuggestions()
    func didSelectItem(at index: Int)
    func didSelectGenre(at index: Int)
    func didSelectCategory(_ category: MediaCategory)
    var selectedGenreIndex:Int? { set get }
    var source: MoviesListSource { get }
    
}

protocol MoviesListViewModelOutput {
    var items: Observable<[MoviesListItemViewModel]> { get } /// Also we can calculate view model items on demand:  https://github.com/kudoleh/iOS-Clean-Architecture-MVVM/pull/10/files
    var loading: Observable<MoviesListViewModelLoading?> { get }
    var query: Observable<String> { get }
    var error: Observable<String> { get }
    var isEmpty: Bool { get }
    var screenTitle: String { get }
    var emptyDataTitle: String { get }
    var errorTitle: String { get }
    var searchBarPlaceholder: String { get }
    var genres: Observable<[Genre]> { get }
    var resetGenres: Observable<Bool> { get }
    var canLoadNextPage: Bool { get }
    var selectedCategory: Observable<MediaCategory> { get }
}

typealias MoviesListViewModel = MoviesListViewModelInput & MoviesListViewModelOutput

final class DefaultMoviesListViewModel: MoviesListViewModel {
    
    private let searchMoviesUseCase: SearchMoviesUseCase
    private let fetchGenresUseCase: FetchGenresUseCase
    private let actions: MoviesListViewModelActions?
    private var allMovies: [Movie] = []
    let genres: Observable<[Genre]> = Observable([])

    var canLoadNextPage: Bool {
        selectedGenreIndex == 0 && hasMorePages && loading.value == .none
    }
    var resetGenres: Observable<Bool> = .init(false)
    var selectedGenreIndex: Int? = 0
    var currentPage: Int = 0
    var totalPageCount: Int = 1
    var hasMorePages: Bool { currentPage < totalPageCount }
    var nextPage: Int { hasMorePages ? currentPage + 1 : currentPage }
    
    private var pages: [MoviesPage] = []
    private var moviesLoadTask: Cancellable? { willSet { moviesLoadTask?.cancel() } }
    private let mainQueue: DispatchQueueType
    private var filteredMovies: [Movie] = []
    let source: MoviesListSource
    private let fetchMoviesSectionUseCase: FetchMoviesSectionUseCase
    // MARK: - OUTPUT
    
    let items: Observable<[MoviesListItemViewModel]> = Observable([])
    let loading: Observable<MoviesListViewModelLoading?> = Observable(.none)
    let query: Observable<String> = Observable("")
    let error: Observable<String> = Observable("")
    let selectedCategory = Observable<MediaCategory>(.movies)
    var isEmpty: Bool { return items.value.isEmpty }
    var screenTitle: String {
        switch source {
        case .search:
            return NSLocalizedString("Movies", comment: "")

        case .nowPlaying:
            return NSLocalizedString("Now Playing", comment: "")

        case .popular:
            return NSLocalizedString("Popular", comment: "")

        case .topRated:
            return NSLocalizedString("Top Rated", comment: "")

        case .upcoming:
            return NSLocalizedString("Upcoming", comment: "")
        }
    }
    let emptyDataTitle = NSLocalizedString("No Found", comment: "")
    let errorTitle = NSLocalizedString("Error", comment: "")
    let searchBarPlaceholder =  NSLocalizedString("Search movies, TV shows...", comment: "")
    
    // MARK: - Init
    
    init(
        source: MoviesListSource,
        searchMoviesUseCase: SearchMoviesUseCase,
        fetchGenresUseCase: FetchGenresUseCase,
        fetchMoviesSectionUseCase: FetchMoviesSectionUseCase,
        actions: MoviesListViewModelActions? = nil,
        mainQueue: DispatchQueueType = DispatchQueue.main
    ) {
        self.source = source
        self.searchMoviesUseCase = searchMoviesUseCase
        self.fetchGenresUseCase = fetchGenresUseCase
        self.fetchMoviesSectionUseCase = fetchMoviesSectionUseCase
        self.actions = actions
        self.mainQueue = mainQueue
    }
    
    // MARK: - Private
    
    private func appendPage(_ moviesPage: MoviesPage) {
        currentPage = moviesPage.page
        totalPageCount = moviesPage.totalPages
        
        pages = pages
            .filter { $0.page != moviesPage.page }
        + [moviesPage]
        self.allMovies = pages.movies
        items.value = pages.movies.map {
            MoviesListItemViewModel(
                movie: $0,
                category: selectedCategory.value
            )
        }
    }
    
    private func resetPages() {
        currentPage = 0
        totalPageCount = 1
        pages.removeAll()
        items.value.removeAll()
    }
    
    private func load(movieQuery: MovieQuery, loading: MoviesListViewModelLoading) {
        self.loading.value = loading
        if movieQuery.query != defaultQuery(for: .movies),
           movieQuery.query != defaultQuery(for: .tvShows) {
            query.value = movieQuery.query
        }
        
        moviesLoadTask = searchMoviesUseCase.execute(
            requestValue: .init(query: movieQuery,category: selectedCategory.value, page: nextPage),
            cached: { [weak self] page in
                self?.mainQueue.async {
                    self?.appendPage(page)
                }
            },
            completion: { [weak self] result in
                self?.mainQueue.async {
                    switch result {
                    case .success(let page):
                        self?.appendPage(page)
                    case .failure(let error):
                        self?.handle(error: error)
                    }
                    self?.loading.value = .none
                }
            })
    }
    private func loadSection(
        loading: MoviesListViewModelLoading
    ) {
        self.loading.value = loading

        moviesLoadTask = fetchMoviesSectionUseCase.execute(
            source: source,
            category: selectedCategory.value,
            page: nextPage
        ) { [weak self] result in
            self?.mainQueue.async {
                guard let self = self else { return }

                switch result {
                case .success(let page):
                    self.appendPage(page)

                case .failure(let error):
                    self.handle(error: error)
                }

                self.loading.value = .none
            }
        }
    }
    private func handle(error: Error) {
        self.error.value = error.isInternetConnectionError ?
        NSLocalizedString("No internet connection", comment: "") :
        NSLocalizedString("Failed loading movies", comment: "")
    }
    
    private func update(movieQuery: MovieQuery) {
        resetPages()
        load(movieQuery: movieQuery, loading: .fullScreen)
    }
    // MARK: - Private
    
    private func loadGenres() {
            
            _ = fetchGenresUseCase.execute (category: selectedCategory.value ){ [weak self] result in
                
                self?.mainQueue.async {
                    
                    switch result {
                        
                    case .success(let genres):
                        self?.genres.value = genres
                        
                    case .failure(let error):
                        print("Error loading genres:", error)
                    }
                }
            }
        }
    }

// MARK: - INPUT. View event methods

extension DefaultMoviesListViewModel {
    
    func viewDidLoad() {
        loadGenres()
        loadInitialMovies()
    }
    func loadInitialMovies() {
        switch source {
        case .search:
            defaultSearchState()

        case .nowPlaying, .popular, .topRated, .upcoming:
            resetPages()
            loadSection(loading: .fullScreen)
        }
    }
    func didLoadNextPage() {
        guard canLoadNextPage else { return }

        switch source {
        case .search:
            let paginationQuery = query.value.isEmpty
                ? "movie"
                : query.value

            load(
                movieQuery: MovieQuery(query: paginationQuery),
                loading: .nextPage
            )

        case .nowPlaying, .popular, .topRated, .upcoming:
            loadSection(loading: .nextPage)
        }
    }

    func didSearch(query: String) {
        guard source == .search,!query.isEmpty else {return
        }
        update(movieQuery: MovieQuery(query: query))
    }

    func didCancelSearch() {
            guard source == .search else {return}
            moviesLoadTask?.cancel()
            defaultSearchState()
        }

    func defaultSearchState() {
        selectedGenreIndex = 0
        resetGenres.value = true
            update(movieQuery: MovieQuery(query: "movie"))
            query.value = ""
        }
    func didSelectCategory(_ category: MediaCategory) {
        guard selectedCategory.value != category else { return }

        let currentQuery = query.value

        selectedCategory.value = category
        selectedGenreIndex = 0
        resetGenres.value = true

        loadGenres()

        switch source {
        case .search:
            let searchQuery = currentQuery.isEmpty
                ? defaultQuery(for: category)
                : currentQuery

            update(
                movieQuery: MovieQuery(query: searchQuery)
            )

            if currentQuery.isEmpty {
                query.value = ""
            }

        case .nowPlaying, .popular, .topRated, .upcoming:
            resetPages()
            loadSection(loading: .fullScreen)
        }
    }
    private func defaultQuery(
        for category: MediaCategory
    ) -> String {
        switch category {
        case .movies:
            return "movie"

        case .tvShows:
            return "tv"
        }
    }
    func showQueriesSuggestions() {
        actions?.showMovieQueriesSuggestions(update(movieQuery:))
    }

    func closeQueriesSuggestions() {
        actions?.closeMovieQueriesSuggestions()
    }
    func didSelectItem(at index: Int) {
        let movies = selectedGenreIndex == 0 ? allMovies: filteredMovies
        guard movies.indices.contains(index) else { return }

        actions?.showMovieDetails(movies[index])
    }
    func didSelectGenre(at index: Int) {
        selectedGenreIndex = index 
        if index == 0 {
            items.value = allMovies.map {
                MoviesListItemViewModel(
                    movie: $0,
                    category: selectedCategory.value
                )
            }
            return
        }

        let selectedGenre = genres.value[index - 1]

        filteredMovies = allMovies.filter {
            $0.genreIds?.contains(selectedGenre.id) ?? false
        }

        items.value = filteredMovies.map {
            MoviesListItemViewModel(
                movie: $0,
                category: selectedCategory.value
            )
        }
    }
}

// MARK: - Private

private extension Array where Element == MoviesPage {
    var movies: [Movie] { flatMap { $0.movies } }
}
