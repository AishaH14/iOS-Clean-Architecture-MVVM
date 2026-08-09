//
//  CreateSessionUseCase.swift
//  ExampleMVVM
//
//  Created by Aisha Hudasi on 01/01/1448 AH.
//

import Foundation

protocol CreateSessionUseCase {
    @discardableResult
    func execute(
        requestToken: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) -> Cancellable?
}

final class DefaultCreateSessionUseCase: CreateSessionUseCase {

    // MARK: - Properties
    private let authRepository: AuthRepository

    // MARK: - Init
    init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }

    // MARK: - CreateSessionUseCase
    @discardableResult
    func execute(
        requestToken: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) -> Cancellable? {
        authRepository.createSession(
            requestToken: requestToken,
            completion: completion
        )
    }
}
