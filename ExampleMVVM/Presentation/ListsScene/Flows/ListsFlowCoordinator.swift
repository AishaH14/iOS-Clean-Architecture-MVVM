//
//  ListsFlowCoordinator.swift
//  ExampleMVVM
//
//  Created by Aisha Hudasi on 13/01/1448 AH.
//

import UIKit

protocol ListsFlowCoordinatorDependencies {
    func makeListsViewController(actions: ListsViewModelActions) -> ListsViewController
    func makeCreateListViewController(actions: CreateListViewModelActions) -> CreateListViewController
    func makeMediaListViewController(source: MediaListSource) -> MediaListViewController
    func makeLoginViewController(actions: LoginViewModelActions) -> LoginViewController
    func makeAuthorizeViewController(actions: AuthorizeViewModelActions) -> AuthorizeViewController
}

final class ListsFlowCoordinator {
    
    private weak var navigationController: UINavigationController?
    private let dependencies: ListsFlowCoordinatorDependencies
    private weak var listsViewController: ListsViewController?
    
    init(
        navigationController: UINavigationController,
        dependencies: ListsFlowCoordinatorDependencies
    ) {
        self.navigationController = navigationController
        self.dependencies = dependencies
    }
    
    func start() {
        let actions = ListsViewModelActions(
            showCreateList: showCreateList,
            showListDetails: showListDetails,
            showAuthorization: showAuthorization
        )
        let viewController = dependencies.makeListsViewController(actions: actions)
        listsViewController = viewController
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func showCreateList() {
        let actions = CreateListViewModelActions(
            didCreateList: didCreateList
        )
        
        let viewController = dependencies.makeCreateListViewController(actions: actions)
        navigationController?.pushViewController(viewController, animated: true)
    }
    private func didCreateList() {
        navigationController?.popViewController(animated: true)
        listsViewController?.refreshLists()
    }
    private func showListDetails(_ list: MovieList) {
        let viewController = dependencies.makeMediaListViewController(source: .list(list))
        navigationController?.pushViewController(viewController, animated: true)
        
    }
    private func showAuthorization() {
        let viewController = dependencies.makeLoginViewController(
            actions: LoginViewModelActions(
                showAuthorize: { [weak self] in
                    self?.showAuthorize()
                },
                showProfile: { [weak self] in
                    self?.navigationController?.popToRootViewController(animated: true)
                }
            )
        )
        navigationController?.setViewControllers([viewController], animated: true)
    }
    private func showAuthorize() {
        let viewController = dependencies.makeAuthorizeViewController(
            actions: AuthorizeViewModelActions(
                showProfile: { [weak self] in
                    self?.navigationController?.popToRootViewController(animated: true)
                }
            )
        )

        navigationController?.pushViewController(viewController, animated: true)
    }
}
