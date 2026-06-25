//
//  CreateGuestSessionUseCase.swift
//  ExampleMVVM
//
//  Created by Aisha Hudasi on 02/01/1448 AH.
//

import Foundation

protocol CreateGuestSessionUseCase {
    @discardableResult
    func execute(
        completion: @escaping (Result<String, Error>) -> Void
    ) -> Cancellable?
}

final class DefaultCreateGuestSessionUseCase: CreateGuestSessionUseCase {
    private let authRepository: AuthRepository
    init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }
    
    // MARK: - CreateGuestSessionUseCase
    @discardableResult
    func execute(
        completion: @escaping (Result<String, Error>) -> Void
    ) -> Cancellable? {
        authRepository.createGuestSession(completion: completion)
    }
}
