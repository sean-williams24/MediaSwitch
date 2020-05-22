//
//  SceneDelegate.swift
//  MediaSwitch
//
//  Created by Sean Williams on 06/04/2020.
//  Copyright © 2020 Sean Williams. All rights reserved.
//

import Alamofire
import UIKit

@available(iOS 13.0, *)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    static private let kAccessTokenKey = "access-token-key"
    private let redirectUri = URL(string:"media-switch://spotify-login-callback")!
    
    var accessToken = UserDefaults.standard.string(forKey: kAccessTokenKey) {
        didSet {
            let defaults = UserDefaults.standard
            defaults.set(accessToken, forKey: SceneDelegate.kAccessTokenKey)
        }
    }
    
    lazy var appRemote: SPTAppRemote = {
        let configuration = SPTConfiguration(clientID: Auth.spotifyClientID, redirectURL: self.redirectUri)
        let appRemote = SPTAppRemote(configuration: configuration, logLevel: .debug)
        appRemote.connectionParameters.accessToken = self.accessToken
        return appRemote
    }()
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else {
            return
        }
        print("scene openURLContexts called")
        
        let parameters = appRemote.authorizationParameters(from: url);
        print(parameters as Any)
        
        if let code = parameters?["code"] {
            UserDefaults.standard.set(code, forKey: "SpotifyAuthCode")
            print(code)
            let baseURL = "https://accounts.spotify.com/api/token"
            
            AF.request(baseURL, method: .post, parameters: ["grant_type": "authorization_code", "code": code, "redirect_uri": redirectUri, "client_id": Auth.spotifyClientID, "client_secret": Auth.spotifyClientSecret], encoding: URLEncoding.default, headers: nil).response { (response) in
                print(response)
                
                switch response.result {
                case .success:
                    print("Got data")
                    
                case .failure(let error):
                    print(error.localizedDescription as Any)
                }
                
                print(Auth.spotifyClientID)
                print(Auth.spotifyClientSecret)
                
                if let data = response.data {
                    do {
                        let readableJSON = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! [String: AnyObject]
                        print(readableJSON)
                        
//                        let accessToken = readableJSON["access_token"] as! String
//                        self.accessToken = accessToken
                        self.SpotifyConnectVC?.connectionEstablished()
                    } catch {
                        print(error)
                    }
                } else {
                    self.SpotifyConnectVC?.showAlert(title: "Connection Failed", message: "Network connection was lost during Spotify authorisation, please try again.")
                }

            }
        }
    }
    
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let _ = (scene as? UIWindowScene) else { return }
    }
    
    
    var SpotifyConnectVC: ConnectVC? {
        get {
            let spotifyViewController = self.window?.rootViewController?.children[0]
            return spotifyViewController as? ConnectVC
        }
    }
}

