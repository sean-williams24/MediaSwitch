//
//  SpotifyAlbum.swift
//  MediaSwitch
//
//  Created by Sean Williams on 07/04/2020.
//  Copyright © 2020 Sean Williams. All rights reserved.
//

import Foundation


// MARK: - Spotify
struct Spotify: Codable {
    let albums: SpotifyAlbums
}

// MARK: - Spotify Albums
struct SpotifyAlbums: Codable {
    let next: JSONNull?
    let total, limit: Int
    let href: String
    let previous: JSONNull?
    let offset: Int
    let items: [SpotifyAlbum]
}

// MARK: - Album
struct SpotifyAlbum: Codable {
    let type: String
    let availableMarkets: [String]
    let externalUrls: ExternalUrls
    let totalTracks: Int
    let albumType: String
    let artists: [Artist]
    let releaseDate, uri, name: String
    let images: [Image]
    let id, releaseDatePrecision: String
    let href: String

    enum CodingKeys: String, CodingKey {
        case type
        case availableMarkets = "available_markets"
        case externalUrls = "external_urls"
        case totalTracks = "total_tracks"
        case albumType = "album_type"
        case artists
        case releaseDate = "release_date"
        case uri, name, images, id
        case releaseDatePrecision = "release_date_precision"
        case href
    }
}

// MARK: - Artist
struct Artist: Codable {
    let name: String
    let href: String
    let externalUrls: ExternalUrls
    let id, type, uri: String

    enum CodingKeys: String, CodingKey {
        case name, href
        case externalUrls = "external_urls"
        case id, type, uri
    }
}

// MARK: - ExternalUrls
struct ExternalUrls: Codable {
    let spotify: String
}

// MARK: - Image
struct Image: Codable {
    let width, height: Int
    let url: String
}

// MARK: - Encode/decode helpers

class JSONNull: Codable, Hashable {

    public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
        return true
    }

//    public var hashValue: Int {
//        return 0
//    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(0)
    }
    
    public init() {}

    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if !container.decodeNil() {
            throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }
}
