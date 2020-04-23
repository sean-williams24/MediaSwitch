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

class SpotifyVC: UIViewController, CAAnimationDelegate {
    
    
    // MARK: - Outlets
    
    @IBOutlet weak var spotifyButton: UIImageView!
    @IBOutlet weak var appleMusicButton: RoundButton!
    
    
    
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
    
    var colourSets = [[CGColor]]()
    var currentColourSet: Int!
    var gradientLayer = CAGradientLayer()
    var colourTimer = Timer()

    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(connectToSpotifyTapped))
        spotifyButton.isUserInteractionEnabled = true
        spotifyButton.addGestureRecognizer(tapGesture)
        
        createColorSets()
        
        gradientLayer.frame = CGRect(x: 0, y: 0, width: appleMusicButton.frame.width - 40, height: appleMusicButton.frame.height)
        gradientLayer.cornerRadius = 25
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.colors = colourSets[currentColourSet]
        appleMusicButton.layer.addSublayer(gradientLayer)
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        
        animateColours()
        colourTimer = Timer.scheduledTimer(timeInterval: 4.5, target: self, selector: #selector(animateColours), userInfo: nil, repeats: true)

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        colourTimer.invalidate()
    }
    
    
    // MARK: - Private Methods
    
    func createColorSets() {
        colourSets.append([UIColor.systemPink.cgColor, UIColor.systemBlue.cgColor])
        colourSets.append([UIColor.systemPurple.cgColor, UIColor.systemPink.cgColor])
        colourSets.append([UIColor.systemBlue.cgColor, UIColor.systemPink.cgColor])
     
        currentColourSet = 0
    }
    
    @objc func animateColours() {
        if currentColourSet < colourSets.count - 1 {
            currentColourSet! += 1
        } else {
            currentColourSet! = 0
        }
        
        let colourChangeAnimation = CABasicAnimation(keyPath: "colors")
        colourChangeAnimation.duration = 1.5
        colourChangeAnimation.toValue = colourSets[currentColourSet]
        colourChangeAnimation.fillMode = .forwards
        colourChangeAnimation.isRemovedOnCompletion = false
        colourChangeAnimation.delegate = self
        gradientLayer.add(colourChangeAnimation, forKey: "colorChange")
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag {
            gradientLayer.colors = colourSets[currentColourSet]
        }
    }
    
    
    func connectionEstablished() {
        print("Perform segue")
        performSegue(withIdentifier: "showImageReader", sender: self)
    }
    
    // MARK: - Action Methods
    
    
    @IBAction func appleMusicButtonTapped(_ sender: Any) {
        
        
    }
    
    
    
    @objc func connectToSpotifyTapped() {
        
        UIView.animate(withDuration: 0.1, animations: {
            self.spotifyButton.transform = CGAffineTransform(scaleX: 0.97, y: 0.97)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.spotifyButton.transform = CGAffineTransform(scaleX: 1, y: 1)
            }
        }
        
        let accessToken = UserDefaults.standard.string(forKey: "access-token-key") ?? "NO_ACCESS_TOKEN"
        let searchURL = "https://api.spotify.com/v1/search?"

        AF.request(searchURL, method: .get, parameters: ["q": "stevelukather", "type": "album"], encoding: URLEncoding.default, headers: ["Authorization": "Bearer "+accessToken]).responseJSON { (response) in
            
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
