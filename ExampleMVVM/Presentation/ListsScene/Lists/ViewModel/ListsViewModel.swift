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
    let showAuthorization: () -> Void
}

protocol ListsViewModelInput {
    func viewDidLoad()
    func didTapCreateList()
    func didRequestDeleteList(at index: Int)
    func didSelectList(at index: Int)
    func didReachEndOfList()
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
    
    private let initialPage = 1
    private var currentPage = 1
    private var isLoading = false
    private var canLoadMore = true
    private var accountId: Int?
    private var sessionId: String?
    
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
        switch authSessionStorage.listsAuthorizationState() {
        case .authenticated(let sessionId):
            fetchAccountDetails(sessionId: sessionId)
            
        case .guest:
            actions.showAuthorization()
            
        case .missing:
            error.value = NSLocalizedString("Missing session id", comment: "")
        }
    }
    
    func didTapCreateList() {
        switch authSessionStorage.listsAuthorizationState() {
        case .authenticated:
            actions.showCreateList()
            
        case .guest:
            actions.showAuthorization()
            
        case .missing:
            error.value = NSLocalizedString("Missing session id", comment: "")
        }
    }
    
    func didRequestDeleteList(at index: Int) {
        guard index < lists.value.count else { return }
        
        let sessionId: String
        
        switch authSessionStorage.listsAuthorizationState() {
        case .authenticated(let authenticatedSessionId):
            sessionId = authenticatedSessionId
            
        case .guest:
            actions.showAuthorization()
            return
            
        case .missing:
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
                    self?.error.value = NSLocalizedString(
                        "Failed to delete list",
                        comment: ""
                    )
                }
            }
        }
    }
    
    func didSelectList(at index: Int) {
        switch authSessionStorage.listsAuthorizationState() {
        case .authenticated:
            guard index < lists.value.count else { return }
            let list = lists.value[index]
            actions.showListDetails(list)
            
        case .guest:
            actions.showAuthorization()
            
        case .missing:
            error.value = NSLocalizedString("Missing session id", comment: "")
        }
    }
    
    func didReachEndOfList() {
        guard let accountId = accountId,
              let sessionId = sessionId else {
            return
        }
        
        fetchLists(
            accountId: accountId,
            sessionId: sessionId,
            page: currentPage + 1
        )
    }
    
    // MARK: - Private
    private func fetchAccountDetails(sessionId: String) {
        fetchAccountDetailsUseCase.execute(sessionId: sessionId) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                switch result {
                case .success(let account):
                    self.accountId = account.id
                    self.sessionId = sessionId
                    self.resetPagination()
                    self.lists.value = []
                    self.posterPaths.value = [:]
                    
                    self.fetchLists(
                        accountId: account.id,
                        sessionId: sessionId,
                        page: self.currentPage
                    )
                    
                case .failure:
                    self.error.value = NSLocalizedString(
                        "Failed to fetch account details",
                        comment: ""
                    )
                }
            }
        }
    }
    
    private func resetPagination() {
        currentPage = initialPage
        canLoadMore = true
    }
    
    private func fetchLists(
        accountId: Int,
        sessionId: String,
        page: Int
    ) {
        guard !isLoading, canLoadMore else { return }
        
        isLoading = true
        
        fetchAccountListsUseCase.execute(
            accountId: accountId,
            sessionId: sessionId,
            page: page
        ) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                self.isLoading = false
                
                switch result {
                case .success(let newLists):
                    if newLists.isEmpty {
                        self.canLoadMore = false
                        return
                    }
                    
                    if page == self.initialPage {
                        self.lists.value = newLists
                    } else {
                        self.lists.value += newLists
                    }
                    
                    self.currentPage = page
                    self.fetchPosterPaths(for: newLists)
                    
                case .failure:
                    self.error.value = NSLocalizedString(
                        "Failed to fetch lists",
                        comment: ""
                    )
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
}
