//
//  ListsRepository.swift
//  ExampleMVVM
//
//  Created by Aisha Hudasi on 13/01/1448 AH.
//

import Foundation

protocol ListsRepository {

    @discardableResult
    func fetchAccountDetails(
        sessionId: String,
        completion: @escaping (Result<Account, Error>) -> Void
    ) -> Cancellable?

    @discardableResult
    func fetchAccountLists(
        accountId: Int,
        sessionId: String,
        page: Int,
        completion: @escaping (Result<[MovieList], Error>) -> Void
    ) -> Cancellable?

    @discardableResult
    func createList(
        sessionId: String,
        name: String,
        description: String,
        completion: @escaping (Result<Int, Error>) -> Void
    ) -> Cancellable?

    @discardableResult
    func deleteList(
        listId: Int,
        sessionId: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) -> Cancellable?

    @discardableResult
    func addMovieToList(
        listId: Int,
        sessionId: String,
        movieId: Int,
        completion: @escaping (Result<Void, Error>) -> Void
    ) -> Cancellable?

    @discardableResult
    func fetchListMovies(
        listId: Int,
        completion: @escaping (Result<[Movie], Error>) -> Void
    ) -> Cancellable?

    @discardableResult
    func removeMovieFromList(
        listId: Int,
        sessionId: String,
        movieId: Int,
        completion: @escaping (Result<Void, Error>) -> Void
    ) -> Cancellable?
}
