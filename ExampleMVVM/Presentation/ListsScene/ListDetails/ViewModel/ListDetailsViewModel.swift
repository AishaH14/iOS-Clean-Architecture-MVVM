//
//  ListDetailsViewModel.swift
//  ExampleMVVM
//
//  Created by Aisha Hudasi on 20/01/1448 AH.
//

import Foundation

protocol ListDetailsViewModelInput {
    func viewDidLoad()
}

protocol ListDetailsViewModelOutput {
    var list: MovieList { get }
    var movies: Observable<[Movie]> { get }
    var error: Observable<String> { get }
}

typealias ListDetailsViewModel =
    ListDetailsViewModelInput & ListDetailsViewModelOutput

final class DefaultListDetailsViewModel: ListDetailsViewModel {

    // MARK: - Output
    let list: MovieList
    let movies: Observable<[Movie]> = Observable([])
    let error: Observable<String> = Observable("")

    // MARK: - Properties
    private let fetchListMoviesUseCase: FetchListMoviesUseCase
    private let mainQueue: DispatchQueueType
    private var fetchListMoviesTask: Cancellable? {
        willSet {
            fetchListMoviesTask?.cancel()
        }
    }

    // MARK: - Init
    init(
        list: MovieList,
        fetchListMoviesUseCase: FetchListMoviesUseCase,
        mainQueue: DispatchQueueType = DispatchQueue.main
    ) {
        self.list = list
        self.fetchListMoviesUseCase = fetchListMoviesUseCase
        self.mainQueue = mainQueue
    }

    // MARK: - Input
    func viewDidLoad() {
        fetchListMoviesTask = fetchListMoviesUseCase.execute(
            listId: list.id
        ) { [weak self] result in
            self?.mainQueue.async {
                switch result {
                case .success(let movies):
                    self?.movies.value = movies

                case .failure:
                    self?.error.value = NSLocalizedString(
                        "Failed to fetch list movies",
                        comment: ""
                    )
                }
            }
        }
    }
}
