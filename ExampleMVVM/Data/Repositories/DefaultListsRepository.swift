//
//  DefaultListsRepository.swift
//  ExampleMVVM
//
//  Created by Aisha Hudasi on 13/01/1448 AH.
//

import Foundation

final class DefaultListsRepository {
    
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
        ListsRepositoryError.apiError(
            code: code,
            message: message
        )
    }
}

extension DefaultListsRepository: ListsRepository {
    
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
        
        let endpoint = ListsEndpoints.getAccountLists(
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
        
        let endpoint = ListsEndpoints.createList(
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
        
        let endpoint = ListsEndpoints.deleteList(
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
        
        let endpoint = ListsEndpoints.addMovieToList(
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
        
        let endpoint = ListsEndpoints.removeMovieFromList(
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
        let endpoint = ListsEndpoints.getListDetails(
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
}
