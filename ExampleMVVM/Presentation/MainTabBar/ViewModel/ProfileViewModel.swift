//
//  ProfileViewModel.swift
//  ExampleMVVM
//
//  Created by Aisha Hudasi on 13/01/1448 AH.
//

import Foundation

struct ProfileViewModelActions {
    let showLists: () -> Void
}

protocol ProfileViewModelInput {
    func didTapLists()
}

protocol ProfileViewModelOutput {
}

typealias ProfileViewModel = ProfileViewModelInput & ProfileViewModelOutput

final class DefaultProfileViewModel: ProfileViewModel {
    
    private let actions: ProfileViewModelActions
    
    init(actions: ProfileViewModelActions) {
        self.actions = actions
    }
    
    func didTapLists() {
        actions.showLists()
    }
}
