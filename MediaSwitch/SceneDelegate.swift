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
        
        SpotifyConnectVC?.showBlurredFXView(true)
        let parameters = appRemote.authorizationParameters(from: url);
        
        if let code = parameters?["code"] {
            UserDefaults.standard.set(code, forKey: "SpotifyAuthCode")
            
            AF.request("https://mediaswitch.herokuapp.com/api/token", method: .post, parameters: ["code": code], encoding: URLEncoding.default).response { (response) in
                
                 if let data = response.data {
                        do {
                            let readableJSON = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! [String: AnyObject]                            
                            let accessToken = readableJSON["access_token"] as? String ?? ""
                            self.accessToken = accessToken
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

