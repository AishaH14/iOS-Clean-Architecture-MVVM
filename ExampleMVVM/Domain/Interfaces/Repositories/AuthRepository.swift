//
//  AuthRepository.swift
//  ExampleMVVM
//
//  Created by Aisha Hudasi on 01/01/1448 AH.
//

import Foundation

protocol AuthRepository {
    @discardableResult
    func requestToken(
        completion: @escaping (Result<String, Error>) -> Void
    ) -> Cancellable?

    @discardableResult
    func createSession(
        requestToken: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) -> Cancellable?

    @discardableResult
    func createGuestSession(
        completion: @escaping (Result<String, Error>) -> Void
    ) -> Cancellable?
}
