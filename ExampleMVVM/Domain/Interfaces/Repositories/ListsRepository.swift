//
//  ListsRepository.swift
//  ExampleMVVM
//
//  Created by Aisha Hudasi on 13/01/1448 AH.
//

import Foundation

protocol ListsRepository {
    func fetchAccountDetails(
        sessionId: String,
        completion: @escaping (Result<Account, Error>) -> Void
    )
    
    func fetchAccountLists(
        accountId: Int,
        sessionId: String,
        page: Int,
        completion: @escaping (Result<[MovieList], Error>) -> Void
    )
    func createList(
        sessionId: String,
        name: String,
        description: String,
        completion: @escaping (Result<Int, Error>) -> Void
    )
    func deleteList(
        listId: Int,
        sessionId: String,
        completion: @escaping (Result<Void, Error>) -> Void

    )
    func addMovieToList(
        listId: Int,
        sessionId: String,
        movieId: Int,
        completion: @escaping (Result<Void, Error>) -> Void
    )
}
