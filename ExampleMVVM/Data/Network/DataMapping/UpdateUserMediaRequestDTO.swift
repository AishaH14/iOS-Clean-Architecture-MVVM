//
//  UpdateUserMediaRequestDTO.swift
//  ExampleMVVM
//

import Foundation

struct UpdateFavoriteRequestDTO: Encodable {
    let mediaType: String
    let mediaId: Int
    let favorite: Bool

    enum CodingKeys: String, CodingKey {
        case mediaType = "media_type"
        case mediaId = "media_id"
        case favorite
    }

    init(mediaType: String = APIConstants.MediaTypes.movie, mediaId: Int, favorite: Bool) {
        self.mediaType = mediaType
        self.mediaId = mediaId
        self.favorite = favorite
    }
}

struct UpdateWatchlistRequestDTO: Encodable {
    let mediaType: String
    let mediaId: Int
    let watchlist: Bool

    enum CodingKeys: String, CodingKey {
        case mediaType = "media_type"
        case mediaId = "media_id"
        case watchlist
    }

    init(mediaType: String = APIConstants.MediaTypes.movie, mediaId: Int, watchlist: Bool) {
        self.mediaType = mediaType
        self.mediaId = mediaId
        self.watchlist = watchlist
    }
}
