//
//  LoginViewModel.swift
//  ExampleMVVM
//
//  Created by Aisha Hudasi on 01/01/1448 AH.
//

import Foundation

struct LoginViewModelActions {
    let showAuthorize: () -> Void
    let showProfile: () -> Void
}

protocol LoginViewModelInput {
    func didTapSignIn()
    func didTapContinueAsGuest()
}

protocol LoginViewModelOutput {
    var loading: Observable<Bool> { get }
    var error: Observable<String> { get }
}

typealias LoginViewModel = LoginViewModelInput & LoginViewModelOutput

final class DefaultLoginViewModel: LoginViewModel {
    
    // MARK: - Output
    let loading: Observable<Bool> = Observable(false)
    let error: Observable<String> = Observable("")
    
    // MARK: - Properties
    private let createGuestSessionUseCase: CreateGuestSessionUseCase
    private let authSessionStorage: AuthSessionStorage
    private let actions: LoginViewModelActions
    
    // MARK: - Init
    init(
        createGuestSessionUseCase: CreateGuestSessionUseCase,
        authSessionStorage: AuthSessionStorage,
        actions: LoginViewModelActions
    ) {
        self.createGuestSessionUseCase = createGuestSessionUseCase
        self.authSessionStorage = authSessionStorage
        self.actions = actions
    }
    
    // MARK: - Input
    func didTapSignIn() {
        actions.showAuthorize()
    }
    
    func didTapContinueAsGuest() {
        loading.value = true
        
        createGuestSessionUseCase.execute { [weak self] result in
            DispatchQueue.main.async {
                self?.loading.value = false
                
                switch result {
                case .success(let guestSessionId):
                    self?.authSessionStorage.removeSessionId()
                    self?.authSessionStorage.saveGuestSessionId(guestSessionId)
                    self?.actions.showProfile()
                    
                case .failure:
                    self?.error.value = NSLocalizedString("Failed to create guest session", comment: "")
                }
            }
        }
    }
}
