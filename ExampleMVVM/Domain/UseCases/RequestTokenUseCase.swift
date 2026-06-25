//
//  RequestTokenUseCase.swift
//  ExampleMVVM
//
//  Created by Aisha Hudasi on 01/01/1448 AH.
//

import Foundation

protocol RequestTokenUseCase {
    @discardableResult
    func execute(
        completion: @escaping (Result<String, Error>) -> Void
    ) -> Cancellable?
}

final class DefaultRequestTokenUseCase: RequestTokenUseCase {

    // MARK: - Properties
    private let authRepository: AuthRepository

    // MARK: - Init
    init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }

    // MARK: - RequestTokenUseCase
    @discardableResult
    func execute(
        completion: @escaping (Result<String, Error>) -> Void
    ) -> Cancellable? {
        authRepository.requestToken(completion: completion)
    }
}
