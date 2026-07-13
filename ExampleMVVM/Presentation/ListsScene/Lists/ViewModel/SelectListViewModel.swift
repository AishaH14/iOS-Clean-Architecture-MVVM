//
//  SelectListViewModel.swift
//  ExampleMVVM
//
//  Created by Aisha Hudasi on 20/01/1448 AH.
//

import Foundation

struct SelectListViewModelActions {
    let didAddMovie: (_ listId: Int) -> Void
}

protocol SelectListViewModelInput {
    func viewDidLoad()
    func didSelectList(at index: Int)
}

protocol SelectListViewModelOutput {
    var lists: Observable<[MovieList]> { get }
    var error: Observable<String> { get }
    var selectedListId: Observable<Int?> { get }
}

typealias SelectListViewModel =
    SelectListViewModelInput & SelectListViewModelOutput

final class DefaultSelectListViewModel: SelectListViewModel {

    // MARK: - Output
    let lists: Observable<[MovieList]> = Observable([])
    let error: Observable<String> = Observable("")
    let selectedListId: Observable<Int?>

    // MARK: - Properties
    private let movieId: Int
    private let currentListId: Int?
    private let fetchAccountDetailsUseCase: FetchAccountDetailsUseCase
    private let fetchAccountListsUseCase: FetchAccountListsUseCase
    private let fetchListMoviesUseCase: FetchListMoviesUseCase
    private let addMovieToListUseCase: AddMovieToListUseCase
    private let removeMovieFromListUseCase: RemoveMovieFromListUseCase
    private let authSessionStorage: AuthSessionStorage
    private let actions: SelectListViewModelActions

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

    private var addMovieToListTask: Cancellable? {
        willSet {
            addMovieToListTask?.cancel()
        }
    }

    private var removeMovieFromListTask: Cancellable? {
        willSet {
            removeMovieFromListTask?.cancel()
        }
    }

    // MARK: - Init
    init(
        movieId: Int,
        currentListId: Int?,
        fetchAccountDetailsUseCase: FetchAccountDetailsUseCase,
        fetchAccountListsUseCase: FetchAccountListsUseCase,
        fetchListMoviesUseCase: FetchListMoviesUseCase,
        addMovieToListUseCase: AddMovieToListUseCase,
        removeMovieFromListUseCase: RemoveMovieFromListUseCase,
        authSessionStorage: AuthSessionStorage,
        actions: SelectListViewModelActions
    ) {
        self.movieId = movieId
        self.currentListId = currentListId
        self.fetchAccountDetailsUseCase = fetchAccountDetailsUseCase
        self.fetchAccountListsUseCase = fetchAccountListsUseCase
        self.fetchListMoviesUseCase = fetchListMoviesUseCase
        self.addMovieToListUseCase = addMovieToListUseCase
        self.removeMovieFromListUseCase = removeMovieFromListUseCase
        self.authSessionStorage = authSessionStorage
        self.actions = actions
        self.selectedListId = Observable(currentListId)
    }
}

// MARK: - Input
extension DefaultSelectListViewModel {

    func viewDidLoad() {
        guard let sessionId = authSessionStorage.getSessionId() else {
            error.value = NSLocalizedString(
                "Missing session id",
                comment: ""
            )
            return
        }

        fetchAccountDetailsTask = fetchAccountDetailsUseCase.execute(
            sessionId: sessionId
        ) { [weak self] result in
            switch result {
            case .success(let account):
                self?.fetchLists(
                    accountId: account.id,
                    sessionId: sessionId
                )

            case .failure:
                DispatchQueue.main.async {
                    self?.error.value = NSLocalizedString(
                        "Failed to fetch account details",
                        comment: ""
                    )
                }
            }
        }
    }

    func didSelectList(at index: Int) {
        guard index < lists.value.count else { return }

        guard let sessionId = authSessionStorage.getSessionId() else {
            error.value = NSLocalizedString(
                "Missing session id",
                comment: ""
            )
            return
        }

        let selectedList = lists.value[index]

        if selectedList.id == currentListId {
            actions.didAddMovie(selectedList.id)
            return
        }

        guard let currentListId = currentListId else {
            addMovie(
                to: selectedList.id,
                sessionId: sessionId
            )
            return
        }

        removeMovieFromListTask = removeMovieFromListUseCase.execute(
            listId: currentListId,
            sessionId: sessionId,
            movieId: movieId
        ) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.addMovie(
                        to: selectedList.id,
                        sessionId: sessionId
                    )

                case .failure:
                    self?.error.value = NSLocalizedString(
                        "Failed to move movie to another list",
                        comment: ""
                    )
                }
            }
        }
    }

    private func fetchLists(
        accountId: Int,
        sessionId: String
    ) {
        fetchAccountListsTask = fetchAccountListsUseCase.execute(
            accountId: accountId,
            sessionId: sessionId,
            page: 1
        ) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let lists):
                    self?.lists.value = lists

                case .failure:
                    self?.error.value = NSLocalizedString(
                        "Failed to fetch lists",
                        comment: ""
                    )
                }
            }
        }
    }

    private func addMovie(
        to listId: Int,
        sessionId: String
    ) {
        addMovieToListTask = addMovieToListUseCase.execute(
            listId: listId,
            sessionId: sessionId,
            movieId: movieId
        ) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.selectedListId.value = listId
                    self?.actions.didAddMovie(listId)

                case .failure:
                    self?.error.value = NSLocalizedString(
                        "Failed to add movie to list",
                        comment: ""
                    )
                }
            }
        }
    }
}
