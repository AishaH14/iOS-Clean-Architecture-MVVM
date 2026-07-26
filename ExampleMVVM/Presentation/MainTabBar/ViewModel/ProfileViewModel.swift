//
//  ProfileViewModel.swift
//  ExampleMVVM
//
//  Created by Aisha Hudasi on 13/01/1448 AH.
//

import Foundation

struct ProfileViewModelActions {
    let showLists: () -> Void
    let showSignIn: () -> Void
    let showFavorites: () -> Void
    let showWatchlist: () -> Void
    let logout: () -> Void
}

protocol ProfileViewModelInput {
    func viewDidLoad()
    func didTapLists()
    func didTapSignIn()
    func didSelectFavorites()
    func didSelectWatchlist()
    func didSelectLogout()
}

protocol ProfileViewModelOutput {
    var account: Observable<Account?> { get }
    var isGuest: Observable<Bool> { get }
    var isSignInButtonHidden: Observable<Bool> { get }
    var error: Observable<String> { get }
}

typealias ProfileViewModel = ProfileViewModelInput & ProfileViewModelOutput

final class DefaultProfileViewModel: ProfileViewModel {
    
    // MARK: - Output
    
    let account: Observable<Account?> = Observable(nil)
    let isGuest: Observable<Bool> = Observable(true)
    let isSignInButtonHidden: Observable<Bool> = Observable(false)
    let error: Observable<String> = Observable("")
    
    // MARK: - Properties
    
    private let fetchAccountDetailsUseCase: FetchAccountDetailsUseCase
    private let authSessionStorage: AuthSessionStorage
    private let actions: ProfileViewModelActions
    
    private var fetchAccountDetailsTask: Cancellable? {
        willSet {
            fetchAccountDetailsTask?.cancel()
        }
    }
    
    // MARK: - Init
    
    init(
        fetchAccountDetailsUseCase: FetchAccountDetailsUseCase,
        authSessionStorage: AuthSessionStorage,
        actions: ProfileViewModelActions
    ) {
        self.fetchAccountDetailsUseCase = fetchAccountDetailsUseCase
        self.authSessionStorage = authSessionStorage
        self.actions = actions
    }
    
    // MARK: - Input
    
    func viewDidLoad() {
        updateAuthorizationState()
    }
    
    func didTapLists() {
        actions.showLists()
    }
    
    func didTapSignIn() {
        actions.showSignIn()
    }
    func didSelectFavorites() {
        actions.showFavorites()
    }

    func didSelectWatchlist() {
        actions.showWatchlist()
    }

    func didSelectLogout() {
        actions.logout()
    }
}

// MARK: - Private

private extension DefaultProfileViewModel {
    
    func updateAuthorizationState() {
        switch authSessionStorage.listsAuthorizationState() {
        case .authenticated(let sessionId):
            isGuest.value = false
            isSignInButtonHidden.value = true
            fetchAccountDetails(sessionId: sessionId)
            
        case .guest, .missing:
            account.value = nil
            isGuest.value = true
            isSignInButtonHidden.value = false
        }
    }
    
    func fetchAccountDetails(sessionId: String) {
        fetchAccountDetailsTask = fetchAccountDetailsUseCase.execute(
            sessionId: sessionId
        ) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let account):
                    self?.account.value = account
                    
                case .failure(let error):
                    self?.error.value = error.isInternetConnectionError
                        ? NSLocalizedString(
                            "No internet connection",
                            comment: ""
                        )
                        : NSLocalizedString(
                            "Failed to fetch account details",
                            comment: ""
                        )
                }
            }
        }
    }
}
