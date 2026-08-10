import Foundation

struct APIEndpoints {
    
    static func getAccountDetails(
        with accountRequestDTO: AccountRequestDTO
    ) -> Endpoint<AccountResponseDTO> {
        return Endpoint(
            path: "3/account",
            method: .get,
            queryParametersEncodable: accountRequestDTO
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
