//
//  CreateListViewModel.swift
//  ExampleMVVM
//
//  Created by Aisha Hudasi on 16/01/1448 AH.
//
import Foundation

struct CreateListViewModelActions {
    let didCreateList: () -> Void
}

protocol CreateListViewModelInput {
    func didTapCreateList(name: String, description: String)
}

protocol CreateListViewModelOutput {
    var error: Observable<String> { get }
}

typealias CreateListViewModel = CreateListViewModelInput & CreateListViewModelOutput

final class DefaultCreateListViewModel: CreateListViewModel {
    
    // MARK: - Output
    let error: Observable<String> = Observable("")
    
    // MARK: - Properties
    private let createListUseCase: CreateListUseCase
    private let authSessionStorage: AuthSessionStorage
    private let actions: CreateListViewModelActions
    
    // MARK: - Init
    init(
        createListUseCase: CreateListUseCase,
        authSessionStorage: AuthSessionStorage,
        actions: CreateListViewModelActions
    ) {
        self.createListUseCase = createListUseCase
        self.authSessionStorage = authSessionStorage
        self.actions = actions
    }
    
    // MARK: - Input
    func didTapCreateList(name: String, description: String) {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDescription = description.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedName.isEmpty else {
            error.value = NSLocalizedString("Please enter list name", comment: "")
            return
        }
        
        guard let sessionId = authSessionStorage.getSessionId() else {
            error.value = NSLocalizedString("Missing session id", comment: "")
            return
        }
        
        createListUseCase.execute(
            sessionId: sessionId,
            name: trimmedName,
            description: trimmedDescription
        ) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.actions.didCreateList()
                    
                case .failure:
                    self?.error.value = NSLocalizedString("Failed to create list", comment: "")
                }
            }
        }
    }
}
