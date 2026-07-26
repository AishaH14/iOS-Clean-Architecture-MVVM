//
//  UserMediaEndpoints.swift
//  ExampleMVVM
//
//  Created by Aisha Hudasi on 27/01/1448 AH.
//

import Foundation

private enum ListsAPIPath {
    static let list = "3/list"

    static func accountLists(_ accountId: Int) -> String {
        "3/account/\(accountId)/lists"
    }

    static func listDetails(_ listId: Int) -> String {
        "\(list)/\(listId)"
    }

    static func addListItem(_ listId: Int) -> String {
        "\(listDetails(listId))/add_item"
    }

    static func removeListItem(_ listId: Int) -> String {
        "\(listDetails(listId))/remove_item"
    }
    static func favoriteMovies(_ accountId: Int) -> String {
        "3/account/\(accountId)/favorite/movies"
    }

    static func watchlistMovies(_ accountId: Int) -> String {
        "3/account/\(accountId)/watchlist/movies"
    }

    static func favorite(_ accountId: Int) -> String {
        "3/account/\(accountId)/favorite"
    }

    static func watchlist(_ accountId: Int) -> String {
        "3/account/\(accountId)/watchlist"
    }
}

private enum ListsAPIHeaders {
    static let jsonHeaders: [String: String] = [
        AuthConstants.contentTypeHeader: "application/json;charset=utf-8",
        AuthConstants.acceptHeader: AuthConstants.applicationJSON
    ]
}

struct UserMediaEndpoints {

    static func getAccountLists(
        accountId: Int,
        with listsRequestDTO: ListsRequestDTO
    ) -> Endpoint<ListsResponseDTO> {
        Endpoint(
            path: ListsAPIPath.accountLists(accountId),
            method: .get,
            queryParametersEncodable: listsRequestDTO
        )
    }

    static func createList(
        with sessionRequestDTO: CreateListSessionRequestDTO,
        body createListRequestDTO: CreateListRequestDTO
    ) -> Endpoint<ListActionResponseDTO> {
        Endpoint(
            path: ListsAPIPath.list,
            method: .post,
            headerParameters: ListsAPIHeaders.jsonHeaders,
            queryParametersEncodable: sessionRequestDTO,
            bodyParametersEncodable: createListRequestDTO
        )
    }

    static func deleteList(
        listId: Int,
        with sessionRequestDTO: CreateListSessionRequestDTO
    ) -> Endpoint<ListActionResponseDTO> {
        Endpoint(
            path: ListsAPIPath.listDetails(listId),
            method: .delete,
            headerParameters: ListsAPIHeaders.jsonHeaders,
            queryParametersEncodable: sessionRequestDTO
        )
    }

    static func addMovieToList(
        listId: Int,
        with sessionRequestDTO: CreateListSessionRequestDTO,
        body addMovieRequestDTO: AddMovieToListRequestDTO
    ) -> Endpoint<ListActionResponseDTO> {
        Endpoint(
            path: ListsAPIPath.addListItem(listId),
            method: .post,
            headerParameters: ListsAPIHeaders.jsonHeaders,
            queryParametersEncodable: sessionRequestDTO,
            bodyParametersEncodable: addMovieRequestDTO
        )
    }

    static func getListDetails(
        listId: Int
    ) -> Endpoint<ListDetailsResponseDTO> {
        Endpoint(
            path: ListsAPIPath.listDetails(listId),
            method: .get
        )
    }

    static func removeMovieFromList(
        listId: Int,
        with sessionRequestDTO: CreateListSessionRequestDTO,
        body removeMovieRequestDTO: AddMovieToListRequestDTO
    ) -> Endpoint<ListActionResponseDTO> {
        Endpoint(
            path: ListsAPIPath.removeListItem(listId),
            method: .post,
            headerParameters: ListsAPIHeaders.jsonHeaders,
            queryParametersEncodable: sessionRequestDTO,
            bodyParametersEncodable: removeMovieRequestDTO
        )
    }
    static func getFavoriteMovies(
            accountId: Int,
            sessionId: String,
            page: Int
        ) -> Endpoint<MoviesResponseDTO> {
            Endpoint(
                path: ListsAPIPath.favoriteMovies(accountId),
                method: .get,
                queryParameters: [
                    APIConstants.QueryKeys.sessionId: sessionId,
                    APIConstants.QueryKeys.page: page
                ]
            )
        }

        static func getWatchlistMovies(
            accountId: Int,
            sessionId: String,
            page: Int
        ) -> Endpoint<MoviesResponseDTO> {
            Endpoint(
                path: ListsAPIPath.watchlistMovies(accountId),
                method: .get,
                queryParameters: [
                    APIConstants.QueryKeys.sessionId: sessionId,
                    APIConstants.QueryKeys.page: page
                ]
            )
        }

        static func updateFavorite(
            accountId: Int,
            sessionId: String,
            body requestDTO: UpdateFavoriteRequestDTO
        ) -> Endpoint<ListActionResponseDTO> {
            Endpoint(
                path: ListsAPIPath.favorite(accountId),
                method: .post,
                headerParameters: ListsAPIHeaders.jsonHeaders,
                queryParameters: [
                    APIConstants.QueryKeys.sessionId: sessionId
                ],
                bodyParametersEncodable: requestDTO
            )
        }

        static func updateWatchlist(
            accountId: Int,
            sessionId: String,
            body requestDTO: UpdateWatchlistRequestDTO
        ) -> Endpoint<ListActionResponseDTO> {
            Endpoint(
                path: ListsAPIPath.watchlist(accountId),
                method: .post,
                headerParameters: ListsAPIHeaders.jsonHeaders,
                queryParameters: [
                    APIConstants.QueryKeys.sessionId: sessionId
                ],
                bodyParametersEncodable: requestDTO
            )
        }
    }
