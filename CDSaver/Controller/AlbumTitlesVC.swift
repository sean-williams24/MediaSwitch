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

class AlbumTitlesVC: UITableViewController {
    
    
    // MARK: - Properties

    var albumTitles = [String]()
    var spotifyAlbums: [[SpotifyAlbum]] = []
    var appleMusicAlbums: [[AppleMusicAlbum]] = []
    var viewingAppleMusic: Bool!
    var storefront = ""
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //        albumTitles = ["STEVELUKATHER", "BILLY JOEL RIVER OF DREAMS", "JAMIROQUAI AUTOMATON"]
        //        albumTitles = ["bakkos+the+killing", "slipknot+iowa", "system+of+a+down+toxicity", "Dr+Dre+2001", "jamiroquai%20Automaton"]
        //        albumTitles = ["lady gaga"]
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Search Spotify", style: .done, target: self, action: #selector(albumSearch(_:)))
        
        let controller = SKCloudServiceController()
        
        controller.requestStorefrontCountryCode { (code, error) in
            if error != nil {
                print(error?.localizedDescription as Any)
            } else {
                if let code = code {
                    self.storefront = code
                    print("Got store code: \(code)")
                } else {
                    print("Did not get store code")
                }
            }
        }
        
        requestAppleUserToken()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    // MARK: - Apple Music Methods
    
    
    
    
    // MARK: - Private Methods
    
    fileprivate func requestAppleUserToken() {
        let controller = SKCloudServiceController()
        controller.requestUserToken(forDeveloperToken: Auth.Apple.developerToken) { (userToken, error) in
            guard error == nil else {
                print(error?.localizedDescription as Any)
                return
            }
            if let userToken = userToken {
                Auth.Apple.userToken = userToken
                print("USER TOKEN: " + userToken as Any)
            } else {
                print("Did not get user token")
            }
        }
    }
    
    func appleMusicAlbumSearch() {
        appleMusicAlbums.removeAll()
        let searchURL = "https://api.music.apple.com/v1/catalog/\(storefront)/search?"
        
        AF.request(searchURL, method: .get, parameters: ["term": "slipknot", "types": "albums"], encoding: URLEncoding.default, headers: ["Authorization": "Bearer " + Auth.Apple.developerToken]).responseJSON { (response) in

            switch response.result {
            case .success:
                
                let decoder = JSONDecoder()
                if let data = response.data {
                    do {
                        let appleMusic = try decoder.decode(AppleMusic.self, from: data)
                        let albumsData = appleMusic.results.albums.data
                        
                        print(albumsData)
                        
                        if !albumsData.isEmpty {
                            
                            self.appleMusicAlbums.append(albumsData)
                            print(self.appleMusicAlbums.count)
                            
                            self.viewingAppleMusic = true
                            self.performSegue(withIdentifier: "showSpotifyAlbums", sender: self)

                        }
                    } catch {
                        print(error.localizedDescription)
                    }
                }

            case .failure(let error):
                print(error.localizedDescription as Any)
            }
        }
    }
    
    func spotifyAlbumSearch() {
        spotifyAlbums.removeAll()
        let accessToken = UserDefaults.standard.string(forKey: "access-token-key") ?? "NO_ACCESS_TOKEN"
        let searchURL = "https://api.spotify.com/v1/search?"
        var i = 0
        for CD in albumTitles {
            
            AF.request(searchURL, method: .get, parameters: ["q": CD, "type":"album"], encoding: URLEncoding.default, headers: ["Authorization": "Bearer "+accessToken]).responseJSON { response in

                switch response.result {
                case .success:
                    let decoder = JSONDecoder()
                    let spotify = try? decoder.decode(Spotify.self, from: response.data!)
                    if let albumResults = spotify?.albums.items {
                        if !albumResults.isEmpty {
                            
                            self.spotifyAlbums.append(albumResults)
                        }
                    }
                    
                case .failure(let error):
                    print(error.localizedDescription)
                }
                
                i += 1
                if i == self.albumTitles.count {
                    print("Search complete")
                    self.viewingAppleMusic = false
                    self.performSegue(withIdentifier: "showSpotifyAlbums", sender: self)
                }
            }
        }
    }
    
    @objc func albumSearch(_ button: UIButton) {
        appleMusicAlbumSearch()
    }
    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albumTitles.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AlbumCell", for: indexPath)
        let albumTitle = albumTitles[indexPath.row]
        
        cell.textLabel?.text = albumTitle
        
        return cell
    }
    
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! SpotifyAlbumResultsCVC
        
        if viewingAppleMusic {
            vc.appleAlbumResults = appleMusicAlbums
            vc.viewingAppleMusic = true
        } else {
            vc.spotifyAlbumResults = spotifyAlbums
            vc.viewingAppleMusic = false
        }
        
        
    }
    

}
