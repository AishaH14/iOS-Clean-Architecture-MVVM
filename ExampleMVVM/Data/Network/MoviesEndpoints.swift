//
//  MoviesEndpoints.swift
//  ExampleMVVM
//
//  Created by Aisha Hudasi on 23/02/1448 AH.
//

import Foundation

struct MoviesEndpoints {
    
    static func searchMedia(
        category: MediaCategory,
        with moviesRequestDTO: MoviesRequestDTO
    ) -> Endpoint<MoviesResponseDTO> {
        let path: String

        switch category {
        case .movies:
            path = "3/search/movie"
        case .tvShows:
            path = "3/search/tv"
        }

        return Endpoint(
            path: path,
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
    
    // MARK: - TV
    
    static func getAiringTodayTV(with moviesListRequestDTO: MoviesListRequestDTO) -> Endpoint<MoviesResponseDTO> {
        return Endpoint(
            path: "3/tv/airing_today",
            method: .get,
            queryParametersEncodable: moviesListRequestDTO
        )
    }
    
    static func getOnTheAirTV(with moviesListRequestDTO: MoviesListRequestDTO) -> Endpoint<MoviesResponseDTO> {
        return Endpoint(
            path: "3/tv/on_the_air",
            method: .get,
            queryParametersEncodable: moviesListRequestDTO
        )
    }
    
    static func getPopularTV(with moviesListRequestDTO: MoviesListRequestDTO) -> Endpoint<MoviesResponseDTO> {
        return Endpoint(
            path: "3/tv/popular",
            method: .get,
            queryParametersEncodable: moviesListRequestDTO
        )
    }
    
    static func getTopRatedTV(with moviesListRequestDTO: MoviesListRequestDTO) -> Endpoint<MoviesResponseDTO> {
        return Endpoint(
            path: "3/tv/top_rated",
            method: .get,
            queryParametersEncodable: moviesListRequestDTO
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
}
