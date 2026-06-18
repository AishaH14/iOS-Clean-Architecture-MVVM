//
//  AuthorizeViewModel.swift
//  ExampleMVVM
//
//  Created by Aisha Hudasi on 01/01/1448 AH.
//
import Foundation

struct AuthorizeViewModelActions {
    let showProfile: () -> Void
}

protocol AuthorizeViewModelInput {
    func didTapOpenTMDB()
    func didReturnFromTMDB(requestToken: String)
}

protocol AuthorizeViewModelOutput {
    var openURL: Observable<URL?> { get }
    var error: Observable<String> { get }
}

typealias AuthorizeViewModel = AuthorizeViewModelInput & AuthorizeViewModelOutput

final class DefaultAuthorizeViewModel: AuthorizeViewModel {
    
    // MARK: - Output
    let openURL: Observable<URL?> = Observable(nil)
    let error: Observable<String> = Observable("")
    
    // MARK: - Properties
    private let requestTokenUseCase: RequestTokenUseCase
    private let createSessionUseCase: CreateSessionUseCase
    private let authSessionStorage: AuthSessionStorage
    private let actions: AuthorizeViewModelActions
    private var requestToken: String?
    
    // MARK: - Init
    init(
        requestTokenUseCase: RequestTokenUseCase,
        createSessionUseCase: CreateSessionUseCase,
        authSessionStorage: AuthSessionStorage,
        actions: AuthorizeViewModelActions
    ) {
        self.requestTokenUseCase = requestTokenUseCase
        self.createSessionUseCase = createSessionUseCase
        self.authSessionStorage = authSessionStorage
        self.actions = actions
    }
    
    // MARK: - Input
    func didTapOpenTMDB() {
        requestTokenUseCase.execute { [weak self] result in
            switch result {
            case .success(let token):
                self?.requestToken = token
                UserDefaults.standard.set(token, forKey: "request_token")
                
                let redirectURL = "examplemvvm://auth"
                let encodedRedirectURL = redirectURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? redirectURL
                let urlString = "https://www.themoviedb.org/authenticate/\(token)?redirect_to=\(encodedRedirectURL)"
                
                guard let url = URL(string: urlString) else {
                    DispatchQueue.main.async {
                        self?.error.value = NSLocalizedString("Invalid authentication URL", comment: "")
                    }
                    return
                }
                DispatchQueue.main.async {
                    self?.openURL.value = url
                }
                case .failure:
                    DispatchQueue.main.async {
                        self?.error.value = NSLocalizedString("Failed to create request token", comment: "")
                    }
              }
        }
    }
    
    func didReturnFromTMDB(requestToken: String) {
        createSessionUseCase.execute(requestToken: requestToken) { [weak self] result in
            switch result {
            case .success(let sessionId):
                self?.authSessionStorage.saveSessionId(sessionId)
                
                DispatchQueue.main.async {
                    self?.actions.showProfile()
                }
                
            case .failure:
                DispatchQueue.main.async {
                    self?.error.value = NSLocalizedString("Failed to create session", comment: "")
                }
            }
        }
    }
}
