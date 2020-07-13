//
//  AlbumsAddedVC.swift
//  MediaSwitch
//
//  Created by Sean Williams on 17/04/2020.
//  Copyright © 2020 Sean Williams. All rights reserved.
//

import UIKit

class AlbumsAddedVC: UIViewController {

    // MARK: - Outlets
    
    @IBOutlet weak var resultsTextView: UITextView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var animationView: UIView!
    
    
    // MARK: - Properties

    var failedAlbums: [String] = []
    var numberOfAlbumsAdded: Int!
    var viewingAppleMusic: Bool!
    var circle = UIView()
    var tickImage = UIImageView()
    
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let circleBorderColour = viewingAppleMusic ? .systemPink : Style.Colours.spotifyGreen

        circle = UIView()
        circle.layer.borderWidth = 15
        circle.layer.cornerRadius = 40
        circle.layer.borderColor = circleBorderColour.cgColor
        circle.backgroundColor = .white
        circle.translatesAutoresizingMaskIntoConstraints = false
 
        circle.heightAnchor.constraint(equalToConstant: 80).isActive = true
        circle.widthAnchor.constraint(equalToConstant: 80).isActive = true
        animationView.addSubview(circle)
        circle.centerXAnchor.constraint(equalTo: imageView!.centerXAnchor).isActive = true
        circle.centerYAnchor.constraint(equalTo: imageView!.centerYAnchor).isActive = true
        
        imageView.image = numberOfAlbumsAdded == 0 ? UIImage(named: "cross") : UIImage(named: "tick")
        imageView.tintColor = viewingAppleMusic ? .systemPurple : Style.Colours.spotifyGreen
        animationView.bringSubviewToFront(imageView)
        
        let albums = numberOfAlbumsAdded == 1 ? "album" : "albums"
        var resultsText = ""
        
        if viewingAppleMusic {
            headerLabel.text = "\(numberOfAlbumsAdded!) \(albums) added to your Apple Music library"
            
            if numberOfAlbumsAdded > 0 {
                resultsText = """
                
                The Apple Music app doesn't sync new additions immediately. To sync now:
                
                Mac: File menu -> Library -> Update Cloud Library.
                
                iPhone: add a new track or album / amend a playlist manually in the Music app and your albums added from MediaSwitch will appear.
                
                """
            }
        } else {
            headerLabel.text = "\(numberOfAlbumsAdded!) \(albums) added to your Spotify library"
        }
        
        resultsTextView.text = resultsText
        
        if failedAlbums.count != 0 {
            resultsTextView.text?.append("\n\n\(failedAlbums.count) failed to add (may already be in your library):")
            
            for album in failedAlbums {
                resultsTextView.text?.append("\n\n\(album)")
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIView.animate(withDuration: 2, delay: 0.2, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.6, options: [.curveEaseInOut, .repeat, .autoreverse], animations: {
            self.circle.transform = CGAffineTransform(scaleX: 2, y: 2)
            self.circle.backgroundColor = .black
            self.circle.layer.borderWidth = 4
            self.imageView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            self.imageView.tintColor = .white
        })
    }
}
