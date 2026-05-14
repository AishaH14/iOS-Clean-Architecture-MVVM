//
//  MovieDetailsLocalStorage.swift
//  ExampleMVVM
//
//  Created by Azhar Ghurab on 16/11/1447 AH.
//

import Foundation

protocol MovieDetailsLocalStorage {
    func isFavorite(movieId: String) -> Bool
    func isInWatchlist(movieId: String) -> Bool
    func toggleFavorite(movieId: String)
    func toggleWatchlist(movieId: String)
}

final class UserDefaultsMovieDetailsLocalStorage: MovieDetailsLocalStorage {

    private let favoritesKey = "favorite_movie_ids"
    private let watchlistKey = "watchlist_movie_ids"
    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func isFavorite(movieId: String) -> Bool {
        ids(forKey: favoritesKey).contains(movieId)
    }

    func isInWatchlist(movieId: String) -> Bool {
        ids(forKey: watchlistKey).contains(movieId)
    }

    func toggleFavorite(movieId: String) {
        toggle(movieId: movieId, key: favoritesKey)
    }

    func toggleWatchlist(movieId: String) {
        toggle(movieId: movieId, key: watchlistKey)
    }

    private func ids(forKey key: String) -> [String] {
        userDefaults.array(forKey: key) as? [String] ?? []
    }

    private func toggle(movieId: String, key: String) {
        var movieIds = ids(forKey: key)

        if movieIds.contains(movieId) {
            movieIds.removeAll { $0 == movieId }
        } else {
            movieIds.append(movieId)
        }

        userDefaults.set(movieIds, forKey: key)
    }
}
