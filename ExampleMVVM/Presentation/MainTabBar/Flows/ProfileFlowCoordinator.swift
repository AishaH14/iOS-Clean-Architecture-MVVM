//
//  ProfileFlowCoordinator.swift
//  ExampleMVVM
//
//  Created by Aisha Hudasi on 29/12/1447 AH.
//

import UIKit

protocol ProfileFlowCoordinatorDependencies {
    func makeLoginViewController(actions: LoginViewModelActions) -> LoginViewController
    func makeAuthorizeViewController(actions: AuthorizeViewModelActions) -> AuthorizeViewController
    func makeProfileViewController() -> UIViewController
    func makeAuthSessionStorage() -> AuthSessionStorage
}

final class ProfileFlowCoordinator {

    // MARK: - Properties
    private weak var navigationController: UINavigationController?
    private let dependencies: ProfileFlowCoordinatorDependencies

    // MARK: - Init
    init(
        navigationController: UINavigationController,
        dependencies: ProfileFlowCoordinatorDependencies
    ) {
        self.navigationController = navigationController
        self.dependencies = dependencies
    }

    // MARK: - Start
    func start() {
        let sessionId = dependencies.makeAuthSessionStorage().getSessionId()

        if sessionId != nil {
            let profileViewController = dependencies.makeProfileViewController()
            navigationController?.setViewControllers([profileViewController], animated: false)
        } else {
            let loginViewController = dependencies.makeLoginViewController(
                actions: LoginViewModelActions(
                    showAuthorize: showAuthorize,
                    showProfile: showProfile
                )
            )
            navigationController?.setViewControllers([loginViewController], animated: false)
        }
    }

    // MARK: - Private
    private func showAuthorize() {
        let authorizeViewController = dependencies.makeAuthorizeViewController(
            actions: AuthorizeViewModelActions(
                showProfile:showProfile
            )
        )
        navigationController?.pushViewController(authorizeViewController, animated: true)
    }

    private func showProfile() {
        let profileViewController = dependencies.makeProfileViewController()
        navigationController?.setViewControllers([profileViewController], animated: true)
    }
}
