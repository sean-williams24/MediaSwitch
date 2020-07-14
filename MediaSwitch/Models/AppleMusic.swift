//
//  AppleMusic.swift
//  MediaSwitch
//
//  Created by Sean Williams on 25/04/2020.
//  Copyright © 2020 Sean Williams. All rights reserved.
//

import Foundation


// MARK: - AppleMusic
struct AppleMusic: Codable {
    let results: AppleResults
}

// MARK: - Results
struct AppleResults: Codable {
    let albums: Albums
}

// MARK: - Albums
struct Albums: Codable {
    let data: [AppleMusicAlbum]
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
    let name: String
}

// MARK: - Artwork
struct Artwork: Codable {
    let url: String
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
