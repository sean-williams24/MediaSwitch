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
    
    
    // MARK: - Properties

    var albumTitles = [String]()
    var spotifyAlbums: [[SpotifyAlbum]] = []
    var viewingAppleMusic = false
    
    // MARK: - Lifecycle
    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Search Spotify", style: .done, target: self, action: #selector(albumSearch(_:)))
//
//        if viewingAppleMusic {
//            appleMusicAlbumSearch()
//        } else {
//            spotifyAlbumSearch()
//        }
//
//    }
//
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//    }
    
    // MARK: - Apple Music Methods
    
    class func appleMusicAlbumSearch(with albumTitles: [String], searchCompletion: @escaping ([[AppleMusicAlbum]]) -> ()) {
//        appleMusicAlbums.removeAll()
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
                                    print(appleMusicAlbumGroup.first?.attributes.name)
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
                                        print(appleMusicAlbums.count)
                                    }

                                }
                            }

                        }
                    
                case .failure(let error):
                    print(error.localizedDescription as Any)
                }
                
                i += 1
                print(i)
                if i == albumTitles.count {
                    print("Search complete")
                    searchCompletion(appleMusicAlbums)
                }
//
////                print(i)
//                if i == albumTitles.count {
////                    self.viewingAppleMusic = true
//                    print("Search Complete")
////                    searchCompletion(appleMusicAlbums)
////                    self.performSegue(withIdentifier: "showSpotifyAlbums", sender: self)
//
////                    self.dismiss(animated: true) {
////                        self.performSegue(withIdentifier: "showAlbums", sender: self)
////                    }
//                }
            }
        }
    }
    
    
    // MARK: - Spotify Methods
    
    func spotifyAlbumSearch() {
        spotifyAlbums.removeAll()
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
                                self.spotifyAlbums.append(albumResults)
                            }
                        }
                    }
                    
                case .failure(let error):
                    print(error.localizedDescription)
                }
                
                i += 1
                if i == self.albumTitles.count {
                    print("Search complete")
                    self.viewingAppleMusic = false
//                    self.performSegue(withIdentifier: "showSpotifyAlbums", sender: self)
                }
            }
        }
    }
    
    @objc func albumSearch(_ button: UIButton) {

    }
    
    
//    // MARK: - Table view data source
//
//    override func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return albumTitles.count
//    }
//
//    
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "AlbumCell", for: indexPath)
//        let albumTitle = albumTitles[indexPath.row]
//        
//        cell.textLabel?.text = albumTitle
//        
//        return cell
//    }
//    
//    
//    // Override to support conditional editing of the table view.
//    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//        // Return false if you do not want the specified item to be editable.
//        return true
//    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        let vc = segue.destination as! SpotifyAlbumResultsCVC
//
//        if viewingAppleMusic {
//            vc.appleAlbumResults = appleMusicAlbums
//            vc.viewingAppleMusic = true
//        } else {
//            vc.spotifyAlbumResults = spotifyAlbums
//            vc.viewingAppleMusic = false
//        }
//
//
//    }
    

}
