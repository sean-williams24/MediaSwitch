//
//  SceneDelegate.swift
//  CDSaver
//
//  Created by Sean Williams on 06/04/2020.
//  Copyright © 2020 Sean Williams. All rights reserved.
//

import Alamofire
import UIKit

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
//        appRemote.delegate = self
        return appRemote
    }()
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else {
            return
        }
        print("scene openURLContexts called")
        
        let parameters = appRemote.authorizationParameters(from: url);
        
        if let code = parameters?["code"] {
            UserDefaults.standard.set(code, forKey: "SpotifyAuthCode")
            
            let baseURL = "https://accounts.spotify.com/api/token"
            
            AF.request(baseURL, method: .post, parameters: ["grant_type": "authorization_code", "code": code, "redirect_uri": redirectUri, "client_id": Auth.spotifyClientID, "client_secret": Auth.spotifyClientSecret], encoding: URLEncoding.default, headers: nil).response { (response) in
                
                do {
                    let readableJSON = try JSONSerialization.jsonObject(with: response.data!, options: .mutableContainers) as! [String: AnyObject]
                    
                    let accessToken = readableJSON["access_token"] as! String
                    print(accessToken)
                    self.accessToken = accessToken
                    
                    self.SpotifyConnectVC?.connectionEstablished()
                    
                } catch {
                    print(error)
                }
            }
        }

    }
    
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let _ = (scene as? UIWindowScene) else { return }
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        
    }
    

    
    var SpotifyConnectVC: SpotifyVC? {
        get {
            let spotifyViewController = self.window?.rootViewController?.children[0]
            return spotifyViewController as? SpotifyVC
        }
    }
}

