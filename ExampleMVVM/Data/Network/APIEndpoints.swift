import Foundation

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
    ) -> Endpoint<CreateListResponseDTO> {
        return Endpoint(
            path: "3/list",
            method: .post,
            headerParameters: [
                       "Content-Type": "application/json;charset=utf-8",
                       "Accept": "application/json"
                   ],
                   queryParametersEncodable: sessionRequestDTO,
                   bodyParametersEncodable: createListRequestDTO
               )
           }
    static func deleteList(
        listId: Int,
        with sessionRequestDTO: CreateListSessionRequestDTO
    ) -> Endpoint<CreateListResponseDTO> {
        return Endpoint(
            path: "3/list/\(listId)",
            method: .delete,
            headerParameters: [
                "Content-Type": "application/json;charset=utf-8",
                "Accept": "application/json"
            ],
            queryParametersEncodable: sessionRequestDTO
        )
    }
    static func addMovieToList(
        listId: Int,
        with sessionRequestDTO: CreateListSessionRequestDTO,
        body addMovieRequestDTO: AddMovieToListRequestDTO
    ) -> Endpoint<AddMovieToListResponseDTO> {
        return Endpoint(
            path: "3/list/\(listId)/add_item",
            method: .post,
            headerParameters: [
                "Content-Type": "application/json;charset=utf-8",
                "Accept": "application/json"
            ],
            queryParametersEncodable: sessionRequestDTO,
            bodyParametersEncodable: addMovieRequestDTO
        )
    }
    static func getListDetails(
        listId: Int
    ) -> Endpoint<ListDetailsResponseDTO> {
        Endpoint(
            path: "3/list/\(listId)",
            method: .get
        )
    }
    static func removeMovieFromList(
        listId: Int,
        with sessionRequestDTO: CreateListSessionRequestDTO,
        body removeMovieRequestDTO: AddMovieToListRequestDTO
    ) -> Endpoint<AddMovieToListResponseDTO> {
        Endpoint(
            path: "3/list/\(listId)/remove_item",
            method: .post,
            headerParameters: [
                "Content-Type": "application/json;charset=utf-8",
                "Accept": "application/json"
            ],
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

