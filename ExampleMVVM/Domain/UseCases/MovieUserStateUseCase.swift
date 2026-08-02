//
//  MovieUserStateUseCase.swift
//  ExampleMVVM
//
//  Created by Aisha Hudasi on 19/02/1448 AH.
//

import Foundation

protocol MovieUserStateUseCase {
    
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
    func fetchListMovies(
        listId: Int,
        completion: @escaping (Result<[Movie], Error>) -> Void
    ) -> Cancellable?
    
    @discardableResult
    func fetchFavoriteMovies(
        accountId: Int,
        sessionId: String,
        page: Int,
        completion: @escaping (Result<[Movie], Error>) -> Void
    ) -> Cancellable?
    
    @discardableResult
    func fetchWatchlistMovies(
        accountId: Int,
        sessionId: String,
        page: Int,
        completion: @escaping (Result<[Movie], Error>) -> Void
    ) -> Cancellable?
}

final class DefaultMovieUserStateUseCase: MovieUserStateUseCase {
    
    // MARK: - Properties
    
    private let fetchAccountDetailsUseCase: FetchAccountDetailsUseCase
    private let fetchAccountListsUseCase: FetchAccountListsUseCase
    private let fetchListMoviesUseCase: FetchListMoviesUseCase
    private let fetchFavoriteMoviesUseCase: FetchFavoriteMoviesUseCase
    private let fetchWatchlistMoviesUseCase: FetchWatchlistMoviesUseCase
    
    // MARK: - Init
    
    init(
        fetchAccountDetailsUseCase: FetchAccountDetailsUseCase,
        fetchAccountListsUseCase: FetchAccountListsUseCase,
        fetchListMoviesUseCase: FetchListMoviesUseCase,
        fetchFavoriteMoviesUseCase: FetchFavoriteMoviesUseCase,
        fetchWatchlistMoviesUseCase: FetchWatchlistMoviesUseCase
    ) {
        self.fetchAccountDetailsUseCase = fetchAccountDetailsUseCase
        self.fetchAccountListsUseCase = fetchAccountListsUseCase
        self.fetchListMoviesUseCase = fetchListMoviesUseCase
        self.fetchFavoriteMoviesUseCase = fetchFavoriteMoviesUseCase
        self.fetchWatchlistMoviesUseCase = fetchWatchlistMoviesUseCase
    }
    
    // MARK: - MovieUserStateUseCase
    
    @discardableResult
    func fetchAccountDetails(
        sessionId: String,
        completion: @escaping (Result<Account, Error>) -> Void
    ) -> Cancellable? {
        fetchAccountDetailsUseCase.execute(
            sessionId: sessionId,
            completion: completion
        )
    }
    
    @discardableResult
    func fetchAccountLists(
        accountId: Int,
        sessionId: String,
        page: Int,
        completion: @escaping (Result<[MovieList], Error>) -> Void
    ) -> Cancellable? {
        fetchAccountListsUseCase.execute(
            accountId: accountId,
            sessionId: sessionId,
            page: page,
            completion: completion
        )
    }
    
    @discardableResult
    func fetchListMovies(
        listId: Int,
        completion: @escaping (Result<[Movie], Error>) -> Void
    ) -> Cancellable? {
        fetchListMoviesUseCase.execute(
            listId: listId,
            completion: completion
        )
    }
    
    @discardableResult
    func fetchFavoriteMovies(
        accountId: Int,
        sessionId: String,
        page: Int,
        completion: @escaping (Result<[Movie], Error>) -> Void
    ) -> Cancellable? {
        fetchFavoriteMoviesUseCase.execute(
            accountId: accountId,
            sessionId: sessionId,
            page: page,
            completion: completion
        )
    }
    
    @discardableResult
    func fetchWatchlistMovies(
        accountId: Int,
        sessionId: String,
        page: Int,
        completion: @escaping (Result<[Movie], Error>) -> Void
    ) -> Cancellable? {
        fetchWatchlistMoviesUseCase.execute(
            accountId: accountId,
            sessionId: sessionId,
            page: page,
            completion: completion
        )
    }
}
