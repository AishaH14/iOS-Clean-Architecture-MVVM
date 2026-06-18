//
//  Untitled.swift
//  ExampleMVVM
//
//  Created by Aisha Hudasi on 01/01/1448 AH.
//

import Foundation

final class DefaultAuthRepository: AuthRepository {

    // MARK: - Properties
    private let dataTransferService: DataTransferService
    private let backgroundQueue: DataTransferDispatchQueue

    // MARK: - Init
    init(
        dataTransferService: DataTransferService,
        backgroundQueue: DataTransferDispatchQueue = DispatchQueue.global(qos: .userInitiated)
    ) {
        self.dataTransferService = dataTransferService
        self.backgroundQueue = backgroundQueue
    }

    // MARK: - AuthRepository
    func requestToken(
        completion: @escaping (Result<String, Error>) -> Void
    ) -> Cancellable? {
        let endpoint = AuthEndpoints.requestToken()
        let task = RepositoryTask()

        task.networkTask = dataTransferService.request(
            with: endpoint,
            on: backgroundQueue
        ) { result in
            switch result {
            case .success(let responseDTO):
                completion(.success(responseDTO.requestToken))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        return task
    }

    func createSession(
        requestToken: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) -> Cancellable? {
        let endpoint = AuthEndpoints.createSession(requestToken: requestToken)
        let task = RepositoryTask()

        task.networkTask = dataTransferService.request(
            with: endpoint,
            on: backgroundQueue
        ) { result in
            switch result {
            case .success(let responseDTO):
                completion(.success(responseDTO.sessionId))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        return task
    }

    func createGuestSession(
        completion: @escaping (Result<String, Error>) -> Void
    ) -> Cancellable? {
        let endpoint = AuthEndpoints.guestSession()
        let task = RepositoryTask()

        task.networkTask = dataTransferService.request(
            with: endpoint,
            on: backgroundQueue
        ) { result in
            switch result {
            case .success(let responseDTO):
                completion(.success(responseDTO.guestSessionId))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        return task
    }
}
