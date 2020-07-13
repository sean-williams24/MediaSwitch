//
//  AlbumTitlesVC.swift
//  CDSaver
//
//  Created by Sean Williams on 08/04/2020.
//  Copyright © 2020 Sean Williams. All rights reserved.
//

import Alamofire
import StoreKit
import UIKit


class AlbumSearchClient {
    
    // MARK: - Apple Music
    
    class func appleMusicAlbumSearch(with albumTitles: [String], searchCompletion: @escaping ([[AppleMusicAlbum]], Error?) -> ()) {
        var appleMusicAlbums: [[AppleMusicAlbum]] = []
        let searchURL = "https://api.music.apple.com/v1/catalog/\(Auth.Apple.storefront)/search?"
        var albumIDs: [String] = []
        var i = 0
        
        for CD in albumTitles {
            AF.request(searchURL, method: .get, parameters: ["term": CD, "types": "albums"], encoding: URLEncoding.default, headers: ["Authorization": "Bearer " + Auth.Apple.developerToken]).responseJSON { (response) in
                
                switch response.result {
                case .success:
                    let decoder = JSONDecoder()
                    if let data = response.data {
                        let appleMusic = try? decoder.decode(AppleMusic.self, from: data)
                        
                        if var appleMusicAlbumGroup = appleMusic?.results.albums.data {
                            if !appleMusicAlbumGroup.isEmpty {
                                for album in appleMusicAlbumGroup {
                                    if albumIDs.contains(album.id) {
                                        // if album already exists in previous group remove album from new group
                                        appleMusicAlbumGroup.removeAll(where: {$0.id == album.id})
                                    } else {
                                        albumIDs.append(album.id)
                                    }
                                }
                                
                                if !appleMusicAlbumGroup.isEmpty {
                                    appleMusicAlbums.append(appleMusicAlbumGroup)
                                }
                            }
                        }
                    }
                case .failure(let error):
                    searchCompletion([], error)
                }
                
                i += 1
                if i == albumTitles.count {
                    searchCompletion(appleMusicAlbums, nil)
                }
            }
        }
    }
    
    
    // MARK: - Spotify
    
    class func spotifyAlbumSearch(with albumTitles: [String], searchCompletion: @escaping ([[SpotifyAlbum]], Error?) -> ()) {
        var spotifyAlbums: [[SpotifyAlbum]] = []
        let accessToken = UserDefaults.standard.string(forKey: "access-token-key") ?? "NO_ACCESS_TOKEN"
        let searchURL = "https://api.spotify.com/v1/search?"
        var albumIDs: [String] = []
        var i = 0
        
        for CD in albumTitles {
            AF.request(searchURL, method: .get, parameters: ["q": CD, "type":"album"], encoding: URLEncoding.default, headers: ["Authorization": "Bearer "+accessToken]).responseJSON { response in
                
                switch response.result {
                case .success:
                    let decoder = JSONDecoder()
                    let spotify = try? decoder.decode(Spotify.self, from: response.data!)
                    
                    if var albumResults = spotify?.albums.items {
                        if !albumResults.isEmpty {
                            
                            // Filter out duplicates
                            for album in albumResults {
                                if albumIDs.contains(album.id) {
                                    albumResults.removeAll(where: {$0.id == album.id})
                                } else {
                                    albumIDs.append(album.id)
                                }
                            }
                            
                            if !albumResults.isEmpty {
                                spotifyAlbums.append(albumResults)
                            }
                        }
                    }
                    
                case .failure(let error):
                    print(error.localizedDescription)
                    searchCompletion([], error)
                }
                
                i += 1
                if i == albumTitles.count {
                    print("Search complete")
                    searchCompletion(spotifyAlbums, nil)
                }
            }
        }
    }
}
