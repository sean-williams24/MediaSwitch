//
//  AppleMusic.swift
//  MediaSwitch
//
//  Created by Sean Williams on 25/04/2020.
//  Copyright © 2020 Sean Williams. All rights reserved.
//

import Foundation

//struct AppleResults: Codable {
//    let 
//}

// MARK: - AppleMusic
struct AppleMusic: Codable {
    let results: AppleResults
//    let meta: Meta
}

//struct Meta: Codable {
//    let results: MetaResults
//}
//
//struct MetaResults: Codable {
//    let order: [Albums]
//}
// MARK: - Results
struct AppleResults: Codable {
    let albums: Albums
//    let artists: Artists
}

// MARK: - Albums
struct Albums: Codable {
    let data: [AppleMusicAlbum]
//    let href, next: String
}

// MARK: - AlbumsData
struct AppleMusicAlbum: Codable {
    let attributes: Attributes
    let href, id, type: String
}

// MARK: - Attributes
struct Attributes: Codable {
    let artistName: String
    let artwork: Artwork
//    let copyright: String
//    let genreNames: [String]
//    let isComplete, isMasteredForItunes, isSingle: Bool
    let name: String
//    let playParams: PlayParams
//    let releaseDate: String
//    let trackCount: Int
//    let url: String
//    let editorialNotes: EditorialNotes?
}

// MARK: - Artwork
struct Artwork: Codable {
//    let bgColor: String
//    let height: Int
//    let textColor1, textColor2, textColor3, textColor4: String
    let url: String
//    let width: Int
}

// MARK: - EditorialNotes
struct EditorialNotes: Codable {
    let standard: String
}

// MARK: - PlayParams
struct PlayParams: Codable {
    let id, kind: String
}

// MARK: - Artists
struct Artists: Codable {
    let data: [ArtistsData]
    let href: String
}

// MARK: - ArtistsDatum
struct ArtistsData: Codable {
    let attributes: ArtistAttributes
    let href, id, type: String
}

// MARK: - FluffyAttributes
struct ArtistAttributes: Codable {
    let editorialNotes: EditorialNotes?
    let genreNames: [String]
    let name: String
    let url: String
}
