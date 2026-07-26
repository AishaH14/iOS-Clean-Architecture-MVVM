import UIKit


final class MoviesSceneDIContainer: MoviesSearchFlowCoordinatorDependencies, MoviesHomeFlowCoordinatorDependencies, ProfileFlowCoordinatorDependencies,MovieDetailsFlowCoordinatorDependencies {
    
    struct Dependencies {
        let apiDataTransferService: DataTransferService
        let imageDataTransferService: DataTransferService
    }
    
    private let dependencies: Dependencies

    // MARK: - Persistent Storage
    lazy var moviesQueriesStorage: MoviesQueriesStorage = CoreDataMoviesQueriesStorage(maxStorageLimit: 10)
    lazy var moviesResponseCache: MoviesResponseStorage = CoreDataMoviesResponseStorage()
    lazy var movieDetailsRepository: MovieDetailsRepository = UserDefaultsMovieDetailsRepository()
    lazy var authRepository: AuthRepository = DefaultAuthRepository(
        dataTransferService: dependencies.apiDataTransferService
    )
    lazy var authSessionStorage: AuthSessionStorage = KeychainAuthSessionStorage()
    lazy var userMediaRepository: UserMediaRepository = DefaultUserMediaRepository(
        dataTransferService: dependencies.apiDataTransferService
    )
    init(dependencies: Dependencies) {
        self.dependencies = dependencies        
    }
    
    // MARK: - Use Cases
    func makeSearchMoviesUseCase() -> SearchMoviesUseCase {
        DefaultSearchMoviesUseCase(
            moviesRepository: makeMoviesRepository(),
            moviesQueriesRepository: makeMoviesQueriesRepository()
        )
    }
    func makeFetchGenresUseCase() -> FetchGenresUseCase {
        DefaultFetchGenresUseCase(
            genresRepository: makeGenresRepository())
        }
    func makeMoviesHomeFlowCoordinator(navigationController: UINavigationController) -> MoviesHomeFlowCoordinator {
        MoviesHomeFlowCoordinator(
            navigationController: navigationController,
            dependencies: self
        )
    }
    func makeFetchHomeMoviesUseCase() -> FetchHomeMoviesUseCase {
        DefaultFetchHomeMoviesUseCase(
            moviesRepository: makeMoviesRepository()
        )
    }
    
    func makeFetchRecentMovieQueriesUseCase(
        requestValue: FetchRecentMovieQueriesUseCase.RequestValue,
        completion: @escaping (FetchRecentMovieQueriesUseCase.ResultValue) -> Void
    ) -> UseCase {
        FetchRecentMovieQueriesUseCase(
            requestValue: requestValue,
            completion: completion,
            moviesQueriesRepository: makeMoviesQueriesRepository()
        )
    }
    func makeFetchListMoviesUseCase() -> FetchListMoviesUseCase {
        DefaultFetchListMoviesUseCase(
            userMediaRepository: makeUserMediaRepository()
        )
    }
    func makeFetchFavoriteMoviesUseCase() -> FetchFavoriteMoviesUseCase {
        DefaultFetchFavoriteMoviesUseCase(
            userMediaRepository: makeUserMediaRepository()
        )
    }

    func makeFetchWatchlistMoviesUseCase() -> FetchWatchlistMoviesUseCase {
        DefaultFetchWatchlistMoviesUseCase(
            userMediaRepository: makeUserMediaRepository()
        )
    }
    func makeUpdateFavoriteUseCase() -> UpdateFavoriteUseCase {
        DefaultUpdateFavoriteUseCase(
            userMediaRepository: userMediaRepository
        )
    }

    func makeUpdateWatchlistUseCase() -> UpdateWatchlistUseCase {
        DefaultUpdateWatchlistUseCase(
            userMediaRepository: userMediaRepository
        )
    }
    func makeAuthSessionStorage() -> AuthSessionStorage {
        return authSessionStorage
    }

    func makeProfileFlowCoordinator(
        navigationController: UINavigationController
    ) -> ProfileFlowCoordinator {
        ProfileFlowCoordinator(
            navigationController: navigationController,
            dependencies: self
        )
    }
    func makeLoginViewController(actions: LoginViewModelActions) -> LoginViewController {
        LoginViewController.create(with: makeLoginViewModel(actions: actions))
    }

    private func makeLoginViewModel(actions: LoginViewModelActions) -> LoginViewModel {
        DefaultLoginViewModel(
            createGuestSessionUseCase: makeCreateGuestSessionUseCase(),
            authSessionStorage: makeAuthSessionStorage(),
            actions: actions
        )
    }
    private func makeCreateGuestSessionUseCase() -> CreateGuestSessionUseCase {
        DefaultCreateGuestSessionUseCase(authRepository: makeAuthRepository())
    }

    func makeAuthorizeViewController(actions: AuthorizeViewModelActions) -> AuthorizeViewController {
        AuthorizeViewController.create(with: makeAuthorizeViewModel(actions: actions))
    }

    private func makeAuthorizeViewModel(actions: AuthorizeViewModelActions) -> AuthorizeViewModel {
        DefaultAuthorizeViewModel(
            requestTokenUseCase: makeRequestTokenUseCase(),
            createSessionUseCase: makeCreateSessionUseCase(),
            authSessionStorage: makeAuthSessionStorage(),
            actions: actions
        )
    }

    private func makeRequestTokenUseCase() -> RequestTokenUseCase {
        DefaultRequestTokenUseCase(authRepository: makeAuthRepository())
    }

    private func makeCreateSessionUseCase() -> CreateSessionUseCase {
        DefaultCreateSessionUseCase(authRepository: makeAuthRepository())
    }

    private func makeAuthRepository() -> AuthRepository {
        return authRepository
    }
    private func makeUserMediaRepository() -> UserMediaRepository {
        return userMediaRepository
    }

    func makeFetchAccountListsUseCase() -> FetchAccountListsUseCase {
        DefaultFetchAccountListsUseCase(
            userMediaRepository: makeUserMediaRepository()
        )
    }
    func makeFetchAccountDetailsUseCase() -> FetchAccountDetailsUseCase {
        DefaultFetchAccountDetailsUseCase(
            userMediaRepository: makeUserMediaRepository()
        )
    }
    func makeCreateListUseCase() -> CreateListUseCase {
        DefaultCreateListUseCase(
            userMediaRepository: makeUserMediaRepository()
        )
    }
    func makeDeleteListUseCase() -> DeleteListUseCase {
        DefaultDeleteListUseCase(
            userMediaRepository: makeUserMediaRepository()
        )
    }
    
    // MARK: - Profile
    func makeProfileViewController(actions: ProfileViewModelActions) -> UIViewController {
        let viewController = ProfileViewController.instantiateViewController()
        viewController.viewModel = makeProfileViewModel(actions: actions)
        return viewController
    }

    func makeProfileViewModel(
        actions: ProfileViewModelActions
    ) -> ProfileViewModel {
        DefaultProfileViewModel(
            fetchAccountDetailsUseCase: makeFetchAccountDetailsUseCase(),
            authSessionStorage: makeAuthSessionStorage(),
            actions: actions
        )
    }
    // MARK: - Lists

    func makeListsViewController(actions: ListsViewModelActions) -> ListsViewController {
            let viewController = ListsViewController.instantiateViewController()
            viewController.viewModel = makeListsViewModel(actions: actions)
            viewController.posterImagesRepository = makePosterImagesRepository()
            return viewController
        }

    func makeListsViewModel(actions: ListsViewModelActions) -> ListsViewModel {
        DefaultListsViewModel(
            fetchAccountDetailsUseCase: makeFetchAccountDetailsUseCase(),
            fetchAccountListsUseCase: makeFetchAccountListsUseCase(),
            fetchListMoviesUseCase: makeFetchListMoviesUseCase(),
            deleteListUseCase: makeDeleteListUseCase(),
            authSessionStorage: makeAuthSessionStorage(),
            actions: actions
        )
    }

    func makeCreateListViewController(actions: CreateListViewModelActions
    ) -> CreateListViewController {
        CreateListViewController.create(
            with: makeCreateListViewModel(actions: actions)
        )
    }

    func makeCreateListViewModel(actions: CreateListViewModelActions) -> CreateListViewModel {
        DefaultCreateListViewModel(
            createListUseCase: makeCreateListUseCase(),
            authSessionStorage: makeAuthSessionStorage(),
            actions: actions
        )
    }
  
    func makeMediaListViewController(
        source: MediaListSource
    ) -> MediaListViewController {
        MediaListViewController.create(
            with: makeMediaListViewModel(source: source),
            posterImagesRepository: makePosterImagesRepository()
        )
    }
    func makeMediaListViewModel(
        source: MediaListSource
    ) -> MediaListViewModel {
        DefaultMediaListViewModel(
            source: source,
            fetchListMoviesUseCase: makeFetchListMoviesUseCase(),
            fetchAccountDetailsUseCase: makeFetchAccountDetailsUseCase(),
            fetchFavoriteMoviesUseCase: makeFetchFavoriteMoviesUseCase(),
            fetchWatchlistMoviesUseCase: makeFetchWatchlistMoviesUseCase(),
            authSessionStorage: makeAuthSessionStorage(),
            updateFavoriteUseCase: makeUpdateFavoriteUseCase(),
            updateWatchlistUseCase: makeUpdateWatchlistUseCase(),
            removeMovieFromListUseCase: makeRemoveMovieFromListUseCase(),
        )
    }
    func makeAddMovieToListUseCase() -> AddMovieToListUseCase {
        DefaultAddMovieToListUseCase(
            userMediaRepository: makeUserMediaRepository()
        )
    }
    func makeRemoveMovieFromListUseCase() -> RemoveMovieFromListUseCase {
        DefaultRemoveMovieFromListUseCase(
            userMediaRepository: makeUserMediaRepository()
        )
    }
    func makeSelectListViewController(
        movieId: Int,
        currentListId: Int?,
        actions: SelectListViewModelActions
    ) -> UIViewController {
        SelectListViewController(
            viewModel: makeSelectListViewModel(
                movieId: movieId,
                currentListId: currentListId,
                actions: actions
            )
        )
    }

    func makeSelectListViewModel(
        movieId: Int,
        currentListId: Int?,
        actions: SelectListViewModelActions
    ) -> SelectListViewModel {
        DefaultSelectListViewModel(
            movieId: movieId,
            currentListId: currentListId,
            fetchAccountDetailsUseCase: makeFetchAccountDetailsUseCase(),
            fetchAccountListsUseCase: makeFetchAccountListsUseCase(),
            fetchListMoviesUseCase: makeFetchListMoviesUseCase(),
            addMovieToListUseCase: makeAddMovieToListUseCase(),
            removeMovieFromListUseCase: makeRemoveMovieFromListUseCase(),
            authSessionStorage: makeAuthSessionStorage(),
            actions: actions
        )
    }
    // MARK: - Repositories
    func makeMoviesRepository() -> MoviesRepository {
        DefaultMoviesRepository(
            dataTransferService: dependencies.apiDataTransferService,
            cache: moviesResponseCache
        )
    }
    func makeGenresRepository() -> GenresRepository {
        DefaultGenresRepository(
            dataTransferService: dependencies.apiDataTransferService
        )
    }
    func makeMoviesQueriesRepository() -> MoviesQueriesRepository {
        DefaultMoviesQueriesRepository(
            moviesQueriesPersistentStorage: moviesQueriesStorage
        )
    }
    func makePosterImagesRepository() -> PosterImagesRepository {
        DefaultPosterImagesRepository(
            dataTransferService: dependencies.imageDataTransferService
        )
    }
    
    // MARK: - Movies List
    func makeMoviesListViewController(actions: MoviesListViewModelActions) -> MoviesListViewController {
        MoviesListViewController.create(
            with: makeMoviesListViewModel(actions: actions),
            posterImagesRepository: makePosterImagesRepository()
        )
    }
    
    func makeMoviesListViewModel(actions: MoviesListViewModelActions) -> MoviesListViewModel {
        DefaultMoviesListViewModel(
            searchMoviesUseCase: makeSearchMoviesUseCase(),
            fetchGenresUseCase: makeFetchGenresUseCase(),
            actions: actions
        )
    }
    // MARK: - Home

    func makeHomeViewController(actions: HomeViewModelActions) -> HomeViewController {
        HomeViewController.create(
            with: makeHomeViewModel(actions: actions),
            posterImagesRepository: makePosterImagesRepository()
        )
    }

    func makeHomeViewModel(actions: HomeViewModelActions) -> HomeViewModel {
        DefaultHomeViewModel(
            fetchHomeMoviesUseCase: makeFetchHomeMoviesUseCase(),
            actions: actions
        )
    }
    // MARK: - Movie Details
    func makeMoviesDetailsViewController(
        movie: Movie,
        actions: MovieDetailsViewModelActions
    ) -> UIViewController {
        MovieDetailsViewController.create(
            with: makeMoviesDetailsViewModel(
                movie: movie,
                actions: actions
            )
        )
    }

    func makeMoviesDetailsViewModel(
        movie: Movie,
        actions: MovieDetailsViewModelActions
    ) -> MovieDetailsViewModel {
        DefaultMovieDetailsViewModel(
            movie: movie,
            posterImagesRepository: makePosterImagesRepository(),
            movieDetailsRepository: movieDetailsRepository,
            removeMovieFromListUseCase: makeRemoveMovieFromListUseCase(),
            authSessionStorage: makeAuthSessionStorage(),
            fetchAccountDetailsUseCase: makeFetchAccountDetailsUseCase(),
            fetchAccountListsUseCase: makeFetchAccountListsUseCase(),
            fetchListMoviesUseCase: makeFetchListMoviesUseCase(),
            updateFavoriteUseCase: makeUpdateFavoriteUseCase(),
            updateWatchlistUseCase: makeUpdateWatchlistUseCase(),
            fetchFavoriteMoviesUseCase: makeFetchFavoriteMoviesUseCase(),
            fetchWatchlistMoviesUseCase: makeFetchWatchlistMoviesUseCase(),
            actions: actions,
        )
    }
    // MARK: - Movies Queries Suggestions List

    func makeMoviesQueriesSuggestionsListViewController(
        didSelect: @escaping MoviesQueryListViewModelDidSelectAction
    ) -> UIViewController {
        return MoviesQueriesTableViewController.create(
            with: makeMoviesQueryListViewModel(didSelect: didSelect)
        )
    }

    func makeMoviesQueryListViewModel(
        didSelect: @escaping MoviesQueryListViewModelDidSelectAction
    ) -> MoviesQueryListViewModel {
        DefaultMoviesQueryListViewModel(
            numberOfQueriesToShow: 10,
            fetchRecentMovieQueriesUseCaseFactory: makeFetchRecentMovieQueriesUseCase,
            didSelect: didSelect
        )
    }
    // MARK: - Flow Coordinators
    func makeMoviesSearchFlowCoordinator(navigationController: UINavigationController) -> MoviesSearchFlowCoordinator {
        MoviesSearchFlowCoordinator(
            navigationController: navigationController,
            dependencies: self
        )
    }
    func makeMovieDetailsFlowCoordinator(
        navigationController: UINavigationController
    ) -> MovieDetailsFlowCoordinator {
        MovieDetailsFlowCoordinator(
            navigationController: navigationController,
            dependencies: self
        )
    }
}
