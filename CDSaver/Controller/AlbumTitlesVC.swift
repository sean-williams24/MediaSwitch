//
//  AlbumTitlesVC.swift
//  CDSaver
//
//  Created by Sean Williams on 08/04/2020.
//  Copyright © 2020 Sean Williams. All rights reserved.
//

import Alamofire
import UIKit

class AlbumTitlesVC: UITableViewController {
    
    
    // MARK: - Properties

    var albumTitles = [String]()
    var albumResults = [[Album]]()

    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
//        albumTitles = ["STEVELUKATHER", "BILLY JOEL RIVER OF DREAMS", "JAMIROQUAI AUTOMATON"]
//        albumTitles = ["bakkos+the+killing", "slipknot+iowa", "system+of+a+down+toxicity", "Dr+Dre+2001", "jamiroquai%20Automaton"]

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Search Spotify", style: .done, target: self, action: #selector(albumSearch(_:)))
       
    }

    
    // MARK: - Private Methods

    @objc func albumSearch(_ button: UIButton) {
        
        let accessToken = UserDefaults.standard.string(forKey: "access-token-key") ?? "NO_ACCESS_TOKEN"
        let searchURL = "https://api.spotify.com/v1/search?"
        //        let albumQuery = "q=jamiroquai%20Automaton&type=album"

        var i = 0
        for CD in albumTitles {
            
            AF.request(searchURL, method: .get, parameters: ["q": CD, "type":"album"], encoding: URLEncoding.default, headers: ["Authorization": "Bearer "+accessToken]).responseJSON { response in
                
                switch response.result {
                case .success:
                    let decoder = JSONDecoder()
                    let spotify = try? decoder.decode(Spotify.self, from: response.data!)
//                    print(spotify?.albums.items)
                    if let albumResults = spotify?.albums.items {
//                        print(albumResults)
//                        print("should have results")
                        if !albumResults.isEmpty {
                            self.albumResults.append(albumResults)
//                            print("album found")
                        }
                    }
                    
                case .failure(let error):
                    print(error.localizedDescription)
                }
                
                i += 1
                if i == self.albumTitles.count {
//                    print("Search complete")
                    self.performSegue(withIdentifier: "showSpotifyAlbums", sender: self)
                }
            }
        }
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
        vc.albumResults = self.albumResults
        
    }
    

}
