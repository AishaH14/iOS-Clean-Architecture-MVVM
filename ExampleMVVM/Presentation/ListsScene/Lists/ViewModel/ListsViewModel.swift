//
//  ListsViewModel.swift
//  ExampleMVVM
//
//  Created by Aisha Hudasi on 13/01/1448 AH.
//

import Foundation

struct ListsViewModelActions {
    let showCreateList: () -> Void
    let showListDetails: (MovieList) -> Void

}

protocol ListsViewModelInput {
    func viewDidLoad()
    func didTapCreateList()
    func didRequestDeleteList(at index: Int)
    func didSelectList(at index: Int)
}

protocol ListsViewModelOutput {
    var lists: Observable<[MovieList]> { get }
    var error: Observable<String> { get }
    var posterPaths: Observable<[Int: String]> { get }
}

typealias ListsViewModel = ListsViewModelInput & ListsViewModelOutput

final class DefaultListsViewModel: ListsViewModel {
    
    // MARK: - Output
    let lists: Observable<[MovieList]> = Observable([])
    let error: Observable<String> = Observable("")
    let posterPaths: Observable<[Int: String]> = Observable([:])
    // MARK: - Properties
    private let fetchAccountDetailsUseCase: FetchAccountDetailsUseCase
    private let fetchAccountListsUseCase: FetchAccountListsUseCase
    private let authSessionStorage: AuthSessionStorage
    private let actions: ListsViewModelActions
    private let deleteListUseCase: DeleteListUseCase
    private let fetchListMoviesUseCase: FetchListMoviesUseCase
    // MARK: - Init
    init(
        fetchAccountDetailsUseCase: FetchAccountDetailsUseCase,
        fetchAccountListsUseCase: FetchAccountListsUseCase,
        fetchListMoviesUseCase: FetchListMoviesUseCase,
        deleteListUseCase: DeleteListUseCase,
        authSessionStorage: AuthSessionStorage,
        actions: ListsViewModelActions
    ) {
        self.fetchAccountDetailsUseCase = fetchAccountDetailsUseCase
        self.fetchAccountListsUseCase = fetchAccountListsUseCase
        self.fetchListMoviesUseCase = fetchListMoviesUseCase
        self.deleteListUseCase = deleteListUseCase
        self.authSessionStorage = authSessionStorage
        self.actions = actions
    }
    
    // MARK: - Input
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
                    self?.error.value = NSLocalizedString("Failed to fetch account details", comment: "")
                }
            }
        }
    }
    func didTapCreateList() {
        actions.showCreateList()
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
                    self?.fetchPosterPaths(for: lists)
                case .failure:
                    self?.error.value = NSLocalizedString("Failed to fetch lists", comment: "")
                }
            }
        }
    }
    private func fetchPosterPaths(for lists: [MovieList]) {
        for list in lists {
            fetchListMoviesUseCase.execute(
                listId: list.id
            ) { [weak self] result in
                guard case let .success(movies) = result,
                      let posterPath = movies.first?.posterPath else {
                    return
                }

                DispatchQueue.main.async {
                    var paths = self?.posterPaths.value ?? [:]
                    paths[list.id] = posterPath
                    self?.posterPaths.value = paths
                }
            }
        }
    }
    func didRequestDeleteList(at index: Int) {
        guard index < lists.value.count else { return }
        
        guard let sessionId = authSessionStorage.getSessionId() else {
            error.value = NSLocalizedString("Missing session id", comment: "")
            return
        }
        
        let list = lists.value[index]
        
        deleteListUseCase.execute(
            listId: list.id,
            sessionId: sessionId
        ) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    var updatedLists = self?.lists.value ?? []
                    updatedLists.remove(at: index)
                    self?.lists.value = updatedLists
                    
                case .failure:
                    self?.error.value = NSLocalizedString("Failed to delete list", comment: "")
                }
            }
        }
    }
    func didSelectList(at index: Int) {
        guard index < lists.value.count else { return }
        
        let list = lists.value[index]
        actions.showListDetails(list)
    }
}
