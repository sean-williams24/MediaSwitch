//
//  AddToSpotifyVC.swift
//  CDSaver
//
//  Created by Sean Williams on 17/04/2020.
//  Copyright © 2020 Sean Williams. All rights reserved.
//

import UIKit

class AddToSpotifyVC: UIViewController {

    @IBOutlet weak var resultsTextLabel: UILabel!
    
    var failedAlbums: [String] = []
    var numberOfAlbumsAdded: Int!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        failedAlbums = ["The Killing", "Slipknot"]
        
        resultsTextLabel.text = """
        All Done
        
        \(numberOfAlbumsAdded!) albums added to your Spotify library
        
        
        """
        
        if failedAlbums.count != 0 {
            resultsTextLabel.text?.append("\n\(failedAlbums.count) failed to add:")
            
            for album in failedAlbums {
                resultsTextLabel.text?.append("\n\(album)")
            }
        }
    }

}
