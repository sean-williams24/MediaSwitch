//
//  SpotifyVC.swift
//  CDSaver
//
//  Created by Sean Williams on 06/04/2020.
//  Copyright © 2020 Sean Williams. All rights reserved.
//

import Alamofire
import SwiftyJSON
import UIKit

class SpotifyVC: UIViewController {
    
    
    // MARK: - Outlets
    
    
    
    
    // MARK: - Properties
    
    let redirectUri = URL(string:"media-switch://spotify-login-callback")!
    let albumURI = "4fdfPogS4fhaCtC9lmgzqR"
    
    lazy var configuration: SPTConfiguration = {
        let configuration = SPTConfiguration(clientID: Auth.spotifyClientID, redirectURL: redirectUri)
        configuration.playURI = ""
        return configuration
    }()
    
    lazy var sessionManager: SPTSessionManager = {
        let manager = SPTSessionManager(configuration: configuration, delegate: self)
        return manager
    }()
    
    lazy var appRemote: SPTAppRemote = {
        let appRemote = SPTAppRemote(configuration: configuration, logLevel: .debug)
        appRemote.delegate = self
        return appRemote
    }()
    
    var albumResults = [[Album]]()
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let performSearch = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(albumSearch))
        navigationItem.rightBarButtonItem = performSearch
        
        let addAlbums = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addAlbumsTapped))
        navigationItem.leftBarButtonItem = addAlbums
    }
    
    
    // MARK: - Private Methods
    
    @objc func addAlbumsTapped(_ button: UIButton) {
        let addAlbumsURL = "https://api.spotify.com/v1/me/albums?ids=\(albumURI)"
        let accessToken = UserDefaults.standard.string(forKey: "access-token-key") ?? "NO_ACCESS_TOKEN"
        
        AF.request(addAlbumsURL, method: .put, parameters: ["ids": albumURI], encoding: URLEncoding.default, headers: ["Authorization": "Bearer "+accessToken]).response { (response) in
            
            if let statusCode = response.response?.statusCode {
                if statusCode == 200 {
                    print("Album Added")
                }
            }
        }
    }
    
    @objc func albumSearch(_ button: UIButton) {
        
        let accessToken = UserDefaults.standard.string(forKey: "access-token-key") ?? "NO_ACCESS_TOKEN"
        let searchURL = "https://api.spotify.com/v1/search?"
        //        let albumQuery = "q=jamiroquai%20Automaton&type=album"
        let cdCollection = ["bakkos+the killing", "slipknot+iowa", "system of a down+toxicity", "Dr Dre+2001"]
        
        for CD in cdCollection {
            print(CD)
            AF.request(searchURL, method: .get, parameters: ["q": CD, "type":"album"], encoding: URLEncoding.default, headers: ["Authorization": "Bearer "+accessToken]).responseJSON { response in
                print(response)
                switch response.result {
                case .success:
                    let decoder = JSONDecoder()
                    let spotify = try? decoder.decode(Spotify.self, from: response.data!)
                    
                    if let albumResults = spotify?.albums.items {
                        self.albumResults.append(albumResults)
                    }
                    
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func connectionEstablished() {
        print("Perform segue")
        performSegue(withIdentifier: "showImageReader", sender: self)
    }
    
    // MARK: - Action Methods
    
    @IBAction func connectTapped(_ sender: Any) {
        
        let accessToken = UserDefaults.standard.string(forKey: "access-token-key") ?? "NO_ACCESS_TOKEN"
        let searchURL = "https://api.spotify.com/v1/search?"
        
        AF.request(searchURL, method: .get, parameters: ["q": "a", "type": "album"], encoding: URLEncoding.default, headers: ["Authorization": "Bearer "+accessToken]).responseJSON { (response) in
            if response.response?.statusCode == 200 {
                self.performSegue(withIdentifier: "showImageReader", sender: self)
            } else {
                print(response)
            }
        }
        
        
        
//        AF.request(baseURL, method: .post, parameters: ["grant_type": "authorization_code", "code": code, "redirect_uri": redirectUri, "client_id": Auth.spotifyClientID, "client_secret": Auth.spotifyClientSecret], encoding: URLEncoding.default, headers: nil).response { (response) in
//
//            do {
//                let readableJSON = try JSONSerialization.jsonObject(with: response.data!, options: .mutableContainers) as! [String: AnyObject]
//
//                print(readableJSON)
//
//            } catch {
//                print(error)
//            }
//        }
        
        
        
//        let scope: SPTScope = [.appRemoteControl, .playlistReadPrivate, .userLibraryModify, .userReadEmail]
//                if #available(iOS 11, *) {
//                    // Use this on iOS 11 and above to take advantage of SFAuthenticationSession
//                    sessionManager.initiateSession(with: scope, options: .clientOnly)
//                } else {
//                    // Use this on iOS versions < 11 to use SFSafariViewController
//                    sessionManager.initiateSession(with: scope, options: .clientOnly, presenting: self)
//                }
        
    }
}


// MARK: - Session Manager Delegates

extension SpotifyVC: SPTSessionManagerDelegate {
    
    func sessionManager(manager: SPTSessionManager, didFailWith error: Error) {
        print("session failed \(error.localizedDescription)")
    }
    
    func sessionManager(manager: SPTSessionManager, didRenew session: SPTSession) {
        print("session renewed \(session.description)")
    }
    
    func sessionManager(manager: SPTSessionManager, didInitiate session: SPTSession) {
        print("sessionManager did initiate")
        appRemote.connectionParameters.accessToken = session.accessToken
        print(session.accessToken)
        appRemote.connect()
    }
}


// MARK: - AppRemoteDelegate

extension SpotifyVC: SPTAppRemoteDelegate {
    
    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
        self.appRemote = appRemote
        print("appremoteDidEstablishConnection")
        //        playerViewController.appRemoteConnected()
    }
    
    func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
        print("didFailConnectionAttemptWithError")
        //        playerViewController.appRemoteDisconnect()
    }
    
    func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
        print("didDisconnectWithError")
        //        playerViewController.appRemoteDisconnect()
    }
    
}
