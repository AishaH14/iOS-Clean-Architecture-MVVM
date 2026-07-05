//
//  SelectListViewModel.swift
//  ExampleMVVM
//
//  Created by Aisha Hudasi on 20/01/1448 AH.
//

import Foundation

struct SelectListViewModelActions {
    let didAddMovie: () -> Void
}

protocol SelectListViewModelInput {
    func viewDidLoad()
    func didSelectList(at index: Int)
}

protocol SelectListViewModelOutput {
    var lists: Observable<[MovieList]> { get }
    var error: Observable<String> { get }
}

typealias SelectListViewModel =
    SelectListViewModelInput & SelectListViewModelOutput

final class DefaultSelectListViewModel: SelectListViewModel {

    // MARK: - Output
    let lists: Observable<[MovieList]> = Observable([])
    let error: Observable<String> = Observable("")

    // MARK: - Properties
    private let movieId: Int
    private let fetchAccountDetailsUseCase: FetchAccountDetailsUseCase
    private let fetchAccountListsUseCase: FetchAccountListsUseCase
    private let addMovieToListUseCase: AddMovieToListUseCase
    private let authSessionStorage: AuthSessionStorage
    private let actions: SelectListViewModelActions

    // MARK: - Init
    init(
        movieId: Int,
        fetchAccountDetailsUseCase: FetchAccountDetailsUseCase,
        fetchAccountListsUseCase: FetchAccountListsUseCase,
        addMovieToListUseCase: AddMovieToListUseCase,
        authSessionStorage: AuthSessionStorage,
        actions: SelectListViewModelActions
    ) {
        self.movieId = movieId
        self.fetchAccountDetailsUseCase = fetchAccountDetailsUseCase
        self.fetchAccountListsUseCase = fetchAccountListsUseCase
        self.addMovieToListUseCase = addMovieToListUseCase
        self.authSessionStorage = authSessionStorage
        self.actions = actions
    }
}
// MARK: - Input
extension DefaultSelectListViewModel {

    func viewDidLoad() {
        guard let sessionId = authSessionStorage.getSessionId() else {
            error.value = NSLocalizedString("Missing session id", comment: "")
            return
        }

        fetchAccountDetailsUseCase.execute(sessionId: sessionId) { [weak self] result in
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
    private func fetchLists(accountId: Int, sessionId: String) {
        fetchAccountListsUseCase.execute(
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
    func didSelectList(at index: Int) {
        guard index < lists.value.count else { return }

        guard let sessionId = authSessionStorage.getSessionId() else {
            error.value = NSLocalizedString("Missing session id", comment: "")
            return
        }

        let selectedList = lists.value[index]

        addMovieToListUseCase.execute(
            listId: selectedList.id,
            sessionId: sessionId,
            movieId: movieId
        ) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.actions.didAddMovie()

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
