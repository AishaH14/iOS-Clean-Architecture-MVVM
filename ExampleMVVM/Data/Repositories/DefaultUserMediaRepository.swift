//
//  DefaultUserMediaRepository.swift
//  ExampleMVVM
//
//  Created by Aisha Hudasi on 13/01/1448 AH.
//

import Foundation

final class DefaultUserMediaRepository {
    
    private let dataTransferService: DataTransferService
    private let backgroundQueue: DataTransferDispatchQueue
    
    init(
        dataTransferService: DataTransferService,
        backgroundQueue: DataTransferDispatchQueue = DispatchQueue.global(qos: .userInitiated)
    ) {
        self.dataTransferService = dataTransferService
        self.backgroundQueue = backgroundQueue
    }
    
    private func makeAPIError(
        code: Int,
        message: String
    ) -> Error {
        UserMediaRepositoryError.apiError(
            code: code,
            message: message
        )
    }
}

extension DefaultUserMediaRepository: UserMediaRepository {
    
    @discardableResult
    func fetchAccountDetails(
        sessionId: String,
        completion: @escaping (Result<Account, Error>) -> Void
    ) -> Cancellable? {
        
        let requestDTO = AccountRequestDTO(sessionId: sessionId)
        let endpoint = APIEndpoints.getAccountDetails(with: requestDTO)
        
        let task = RepositoryTask()
        
        task.networkTask = dataTransferService.request(
            with: endpoint,
            on: backgroundQueue
        ) { result in
            switch result {
            case .success(let responseDTO):
                completion(.success(responseDTO.toDomain()))
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
        return task
    }
    
    @discardableResult
    func fetchAccountLists(
        accountId: Int,
        sessionId: String,
        page: Int,
        completion: @escaping (Result<[MovieList], Error>) -> Void
    ) -> Cancellable? {
        
        let requestDTO = ListsRequestDTO(
            sessionId: sessionId,
            page: page
        )
        
        let endpoint = UserMediaEndpoints.getAccountLists(
            accountId: accountId,
            with: requestDTO
        )
        
        let task = RepositoryTask()
        
        task.networkTask = dataTransferService.request(
            with: endpoint,
            on: backgroundQueue
        ) { result in
            switch result {
            case .success(let responseDTO):
                completion(.success(responseDTO.toDomain()))
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
        return task
    }
    @discardableResult
    func createList(
        sessionId: String,
        name: String,
        description: String,
        completion: @escaping (Result<Int, Error>) -> Void
    ) -> Cancellable? {
        let sessionRequestDTO = CreateListSessionRequestDTO(
            sessionId: sessionId
        )
        
        let requestDTO = CreateListRequestDTO(
            name: name,
            description: description,
            language: "en"
        )
        
        let endpoint = UserMediaEndpoints.createList(
            with: sessionRequestDTO,
            body: requestDTO
        )
        
        let task = RepositoryTask()
        
        task.networkTask = dataTransferService.request(
            with: endpoint,
            on: backgroundQueue
        ) { result in
            switch result {
            case .success(let responseDTO):
                if responseDTO.success, let listId = responseDTO.listId {
                    completion(.success(listId))
                } else {
                    completion(
                        .failure(
                            self.makeAPIError(
                                code: responseDTO.statusCode,
                                message: responseDTO.statusMessage
                            )
                        )
                    )
                }
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
        return task
    }
    
    @discardableResult
    func deleteList(
        listId: Int,
        sessionId: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) -> Cancellable? {
        let sessionRequestDTO = CreateListSessionRequestDTO(
            sessionId: sessionId
        )
        
        let endpoint = UserMediaEndpoints.deleteList(
            listId: listId,
            with: sessionRequestDTO
        )
        
        let task = RepositoryTask()
        
        task.networkTask = dataTransferService.request(
            with: endpoint,
            on: backgroundQueue
        ) { result in
            switch result {
            case .success(let responseDTO):
                if responseDTO.success {
                    completion(.success(()))
                } else {
                    completion(
                        .failure(
                            self.makeAPIError(
                                code: responseDTO.statusCode,
                                message: responseDTO.statusMessage
                            )
                        )
                    )
                }
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
        return task
    }
    
    @discardableResult
    func addMovieToList(
        listId: Int,
        sessionId: String,
        movieId: Int,
        completion: @escaping (Result<Void, Error>) -> Void
    ) -> Cancellable? {
        let sessionRequestDTO = CreateListSessionRequestDTO(
            sessionId: sessionId
        )
        
        let requestDTO = AddMovieToListRequestDTO(
            mediaId: movieId
        )
        
        let endpoint = UserMediaEndpoints.addMovieToList(
            listId: listId,
            with: sessionRequestDTO,
            body: requestDTO
        )
        
        let task = RepositoryTask()
        
        task.networkTask = dataTransferService.request(
            with: endpoint,
            on: backgroundQueue
        ) { result in
            switch result {
            case .success(let responseDTO):
                if responseDTO.success {
                    completion(.success(()))
                } else {
                    completion(
                        .failure(
                            self.makeAPIError(
                                code: responseDTO.statusCode,
                                message: responseDTO.statusMessage
                            )
                        )
                    )
                }
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
        return task
    }
    
    @discardableResult
    func removeMovieFromList(
        listId: Int,
        sessionId: String,
        movieId: Int,
        completion: @escaping (Result<Void, Error>) -> Void
    ) -> Cancellable? {
        let sessionRequestDTO = CreateListSessionRequestDTO(
            sessionId: sessionId
        )
        
        let requestDTO = AddMovieToListRequestDTO(
            mediaId: movieId
        )
        
        let endpoint = UserMediaEndpoints.removeMovieFromList(
            listId: listId,
            with: sessionRequestDTO,
            body: requestDTO
        )
        
        let task = RepositoryTask()
        
        task.networkTask = dataTransferService.request(
            with: endpoint,
            on: backgroundQueue
        ) { result in
            switch result {
            case .success(let responseDTO):
                if responseDTO.success {
                    completion(.success(()))
                } else {
                    completion(
                        .failure(
                            self.makeAPIError(
                                code: responseDTO.statusCode,
                                message: responseDTO.statusMessage
                            )
                        )
                    )
                }
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
        return task
    }
    
    @discardableResult
    func fetchListMovies(
        listId: Int,
        completion: @escaping (Result<[Movie], Error>) -> Void
    ) -> Cancellable? {
        let endpoint = UserMediaEndpoints.getListDetails(
            listId: listId
        )
        
        let task = RepositoryTask()
        
        task.networkTask = dataTransferService.request(
            with: endpoint,
            on: backgroundQueue
        ) { result in
            switch result {
            case .success(let responseDTO):
                completion(.success(responseDTO.toDomain()))
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
        return task
    }
    
    @discardableResult
    func fetchFavoriteMovies(
        accountId: Int,
        sessionId: String,
        page: Int,
        completion: @escaping (Result<[Movie], Error>) -> Void
    ) -> Cancellable? {
        let endpoint = UserMediaEndpoints.getFavoriteMovies(
            accountId: accountId,
            sessionId: sessionId,
            page: page
        )
        
        let task = RepositoryTask()
        
        task.networkTask = dataTransferService.request(
            with: endpoint,
            on: backgroundQueue
        ) { result in
            switch result {
            case .success(let responseDTO):
                completion(.success(responseDTO.toDomain().movies))
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
        return task
    }
    @discardableResult
    func fetchWatchlistMovies(
        accountId: Int,
        sessionId: String,
        page: Int,
        completion: @escaping (Result<[Movie], Error>) -> Void
    ) -> Cancellable? {

        let endpoint = UserMediaEndpoints.getWatchlistMovies(
            accountId: accountId,
            sessionId: sessionId,
            page: page
        )

        let task = RepositoryTask()

        task.networkTask = dataTransferService.request(
            with: endpoint,
            on: backgroundQueue
        ) { result in
            switch result {
            case .success(let responseDTO):
                completion(.success(responseDTO.toDomain().movies))

            case .failure(let error):
                completion(.failure(error))
            }
        }

        return task
    }
    @discardableResult
    func updateFavorite(
        accountId: Int,
        sessionId: String,
        movieId: Int,
        favorite: Bool,
        completion: @escaping (Result<Void, Error>) -> Void
    ) -> Cancellable? {
        let requestDTO = UpdateFavoriteRequestDTO(
            mediaType: "movie",
            mediaId: movieId,
            favorite: favorite
        )

        let endpoint = UserMediaEndpoints.updateFavorite(
            accountId: accountId,
            sessionId: sessionId,
            body: requestDTO
        )

        let task = RepositoryTask()

        task.networkTask = dataTransferService.request(
            with: endpoint,
            on: backgroundQueue
        ) { result in
            switch result {
            case .success:
                completion(.success(()))

            case .failure(let error):
                completion(.failure(error))
            }
        }

        return task
    }

    @discardableResult
    func updateWatchlist(
        accountId: Int,
        sessionId: String,
        movieId: Int,
        watchlist: Bool,
        completion: @escaping (Result<Void, Error>) -> Void
    ) -> Cancellable? {
        let requestDTO = UpdateWatchlistRequestDTO(
            mediaType: "movie",
            mediaId: movieId,
            watchlist: watchlist
        )

        let endpoint = UserMediaEndpoints.updateWatchlist(
            accountId: accountId,
            sessionId: sessionId,
            body: requestDTO
        )

        let task = RepositoryTask()

        task.networkTask = dataTransferService.request(
            with: endpoint,
            on: backgroundQueue
        ) { result in
            switch result {
            case .success:
                completion(.success(()))

            case .failure(let error):
                completion(.failure(error))
            }
        }

        return task
    }
}
