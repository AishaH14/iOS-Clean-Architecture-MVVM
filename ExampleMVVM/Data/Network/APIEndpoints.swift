import Foundation

private enum APIPath {
    static let list = "3/list"

    static func listDetails(_ listId: Int) -> String {
        "\(list)/\(listId)"
    }

    static func addListItem(_ listId: Int) -> String {
        "\(listDetails(listId))/add_item"
    }

    static func removeListItem(_ listId: Int) -> String {
        "\(listDetails(listId))/remove_item"
    }
}

private enum APIHeaders {
    static let contentType = "Content-Type"
    static let accept = "Accept"
    static let json = "application/json"
    static let jsonWithCharset = "application/json;charset=utf-8"

    static let jsonHeaders: [String: String] = [
        contentType: jsonWithCharset,
        accept: json
    ]
}

struct APIEndpoints {
    
    static func getMovies(with moviesRequestDTO: MoviesRequestDTO) -> Endpoint<MoviesResponseDTO> {

        return Endpoint(
            path: "3/search/multi",
            method: .get,
            queryParametersEncodable: moviesRequestDTO
        )
    }
    static func getNowPlayingMovies(with moviesListRequestDTO: MoviesListRequestDTO) -> Endpoint<MoviesResponseDTO> {
        return Endpoint(
            path: "3/movie/now_playing",
            method: .get,
            queryParametersEncodable: moviesListRequestDTO
        )
    }

    static func getPopularMovies(with moviesListRequestDTO: MoviesListRequestDTO) -> Endpoint<MoviesResponseDTO> {
        return Endpoint(
            path: "3/movie/popular",
            method: .get,
            queryParametersEncodable: moviesListRequestDTO
        )
    }

    static func getTopRatedMovies(with moviesListRequestDTO: MoviesListRequestDTO) -> Endpoint<MoviesResponseDTO> {
        return Endpoint(
            path: "3/movie/top_rated",
            method: .get,
            queryParametersEncodable: moviesListRequestDTO
        )
    }

    static func getUpcomingMovies(with moviesListRequestDTO: MoviesListRequestDTO) -> Endpoint<MoviesResponseDTO> {
        return Endpoint(
            path: "3/movie/upcoming",
            method: .get,
            queryParametersEncodable: moviesListRequestDTO
        )
    }
    static func getAccountDetails(
        with accountRequestDTO: AccountRequestDTO
    ) -> Endpoint<AccountResponseDTO> {
        return Endpoint(
            path: "3/account",
            method: .get,
            queryParametersEncodable: accountRequestDTO
        )
    }
    static func getAccountLists(
        accountId: Int,
        with listsRequestDTO: ListsRequestDTO
    ) -> Endpoint<ListsResponseDTO> {
        return Endpoint(
            path: "3/account/\(accountId)/lists",
            method: .get,
            queryParametersEncodable: listsRequestDTO
        )
    }
    static func createList(
        with sessionRequestDTO: CreateListSessionRequestDTO,
        body createListRequestDTO: CreateListRequestDTO
    ) -> Endpoint<ListActionResponseDTO> {
        return Endpoint(
        path: APIPath.list,
               method: .post,
               headerParameters: APIHeaders.jsonHeaders,
               queryParametersEncodable: sessionRequestDTO,
               bodyParametersEncodable: createListRequestDTO
        )
           }
    static func deleteList(
        listId: Int,
        with sessionRequestDTO: CreateListSessionRequestDTO
    ) -> Endpoint<ListActionResponseDTO> {
        return Endpoint(
            path: APIPath.listDetails(listId),
                    method: .delete,
                    headerParameters: APIHeaders.jsonHeaders,
                    queryParametersEncodable: sessionRequestDTO
                )
    }
    static func addMovieToList(
        listId: Int,
        with sessionRequestDTO: CreateListSessionRequestDTO,
        body addMovieRequestDTO: AddMovieToListRequestDTO
    ) -> Endpoint<ListActionResponseDTO> {
        return Endpoint(
                    path: APIPath.addListItem(listId),
                    method: .post,
                    headerParameters: APIHeaders.jsonHeaders,
                    queryParametersEncodable: sessionRequestDTO,
                    bodyParametersEncodable: addMovieRequestDTO
        )
    }
    static func getListDetails(
        listId: Int
    ) -> Endpoint<ListDetailsResponseDTO> {
        Endpoint(
            path: APIPath.listDetails(listId),
            method: .get
        )
    }
    static func removeMovieFromList(
        listId: Int,
        with sessionRequestDTO: CreateListSessionRequestDTO,
        body removeMovieRequestDTO: AddMovieToListRequestDTO
    ) -> Endpoint<ListActionResponseDTO> {
        Endpoint(
                    path: APIPath.removeListItem(listId),
                    method: .post,
                    headerParameters: APIHeaders.jsonHeaders,
                    queryParametersEncodable: sessionRequestDTO,
                    bodyParametersEncodable: removeMovieRequestDTO
                )
    }
    static func getMoviePoster(path: String, width: Int) -> Endpoint<Data> {

        let sizes = [92, 154, 185, 342, 500, 780]
        let closestWidth = sizes
            .enumerated()
            .min { abs($0.1 - width) < abs($1.1 - width) }?
            .element ?? sizes.first!
        
        return Endpoint(
            path: "t/p/w\(closestWidth)\(path)",
            method: .get,
            responseDecoder: RawDataResponseDecoder()
        )
    }
    // MARK: - Genres
        
        static func getMovieGenres() -> Endpoint<GenresResponseDTO> {
            return Endpoint(
                path: "3/genre/movie/list",
                method: .get
            )
        }
        
        static func getTVGenres() -> Endpoint<GenresResponseDTO> {
            return Endpoint(
                path: "3/genre/tv/list",
                method: .get
            )
        }
    }

