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
    
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        

    }
    
    
    // MARK: - Private Methods
    
//    @objc func addAlbumsTapped(_ button: UIButton) {
//        let addAlbumsURL = "https://api.spotify.com/v1/me/albums?ids=\(albumURI)"
//        let accessToken = UserDefaults.standard.string(forKey: "access-token-key") ?? "NO_ACCESS_TOKEN"
//
//        AF.request(addAlbumsURL, method: .put, parameters: ["ids": albumURI], encoding: URLEncoding.default, headers: ["Authorization": "Bearer "+accessToken]).response { (response) in
//
//            if let statusCode = response.response?.statusCode {
//                if statusCode == 200 {
//                    print("Album Added")
//                }
//            }
//        }
//    }

    
    
    func connectionEstablished() {
        print("Perform segue")
        performSegue(withIdentifier: "showImageReader", sender: self)
    }
    
    // MARK: - Action Methods
    
    @IBAction func connectTapped(_ sender: Any) {
        
        let accessToken = UserDefaults.standard.string(forKey: "access-token-key") ?? "NO_ACCESS_TOKEN"
        let searchURL = "https://api.spotify.com/v1/search?"

        AF.request(searchURL, method: .get, parameters: ["q": "a", "type": "album"], encoding: URLEncoding.default, headers: ["Authorization": "Bearer "+accessToken]).responseJSON { (response) in
            
            switch response.result {
            case .success(let value):
//                print(response.result)
                if let dict = value as? NSDictionary {
                    if let errorCode = dict["error"] as? NSDictionary {
                        if errorCode["status"] as! Int == 401 {
                            print("Token Has Expired")
                            
                            let scope: SPTScope = [.appRemoteControl, .playlistReadPrivate, .userLibraryModify, .userReadEmail]
                            if #available(iOS 11, *) {
                                // Use to take advantage of SFAuthenticationSession
                                self.sessionManager.initiateSession(with: scope, options: .clientOnly)
                            } else {
                                // Use on iOS versions < 11 to use SFSafariViewController
                                self.sessionManager.initiateSession(with: scope, options: .clientOnly, presenting: self)
                            }
                        }
                    } else {
//                        let scope: SPTScope = [.appRemoteControl, .playlistReadPrivate, .userLibraryModify, .userReadEmail]
//                                if #available(iOS 11, *) {
//                                    // Use to take advantage of SFAuthenticationSession
//                                    self.sessionManager.initiateSession(with: scope, options: .clientOnly)
//                                } else {
//                                    // Use on iOS versions < 11 to use SFSafariViewController
//                                    self.sessionManager.initiateSession(with: scope, options: .clientOnly, presenting: self)
//                                }
                        self.performSegue(withIdentifier: "showImageReader", sender: self)
                    }
                }
                
            case .failure(let error):
                print("Fail")
                print(error)
                
            }
            
            //            if response.response?.statusCode == 200 {
            //                self.performSegue(withIdentifier: "showImageReader", sender: self)
            //            } else {
            ////                print(response)
            //            let scope: SPTScope = [.appRemoteControl, .playlistReadPrivate, .userLibraryModify, .userReadEmail]
            //                    if #available(iOS 11, *) {
            //                        // Use this on iOS 11 and above to take advantage of SFAuthenticationSession
            //                        self.sessionManager.initiateSession(with: scope, options: .clientOnly)
            //                    } else {
            //                        // Use this on iOS versions < 11 to use SFSafariViewController
            //                        self.sessionManager.initiateSession(with: scope, options: .clientOnly, presenting: self)
            //                    }
            //            }
        }
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
