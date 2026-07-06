//
//  MovieDetailsFlowCoordinator.swift
//  ExampleMVVM
//
//  Created by Aisha Hudasi on 20/01/1448 AH.
//

import UIKit

protocol MovieDetailsFlowCoordinatorDependencies {
    func makeMoviesDetailsViewController(
        movie: Movie,
        actions: MovieDetailsViewModelActions
    ) -> UIViewController

    func makeSelectListViewController(
        movieId: Int,
        actions: SelectListViewModelActions
    ) -> UIViewController
}

final class MovieDetailsFlowCoordinator {
    
    private weak var navigationController: UINavigationController?
    private let dependencies: MovieDetailsFlowCoordinatorDependencies
    
    init(
        navigationController: UINavigationController,
        dependencies: MovieDetailsFlowCoordinatorDependencies
    ) {
        self.navigationController = navigationController
        self.dependencies = dependencies
    }
    func start(movie: Movie) {
        let actions = MovieDetailsViewModelActions(
            showLists: showLists
        )
        
        let viewController = dependencies.makeMoviesDetailsViewController(
            movie: movie,
            actions: actions
        )
        
        navigationController?.pushViewController(
            viewController,
            animated: true
        )
    }
    private func showLists(
        movieId: Int,
        didAddMovie: @escaping (_ listId: Int) -> Void
    ) {
        let actions = SelectListViewModelActions(
            didAddMovie: { [weak self] listId in
                didAddMovie(listId)

                self?.navigationController?
                    .presentedViewController?
                    .dismiss(animated: true)
            }
        )

        let viewController = dependencies.makeSelectListViewController(
            movieId: movieId,
            actions: actions
        )

        let sheetNavigationController = UINavigationController(
            rootViewController: viewController
        )

        if let sheet = sheetNavigationController.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
        }

        navigationController?.present(
            sheetNavigationController,
            animated: true
        )
    }
}
