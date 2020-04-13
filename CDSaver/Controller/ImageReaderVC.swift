//
//  ImageReaderVC.swift
//  CDSaver
//
//  Created by Sean Williams on 12/02/2020.
//  Copyright © 2020 Sean Williams. All rights reserved.
//

import Firebase
import UIKit

class ImageReaderVC: UIViewController {
    
    // MARK: - Outlets

    @IBOutlet var imageView: UIImageView!
    
    
    // MARK: - Properties
    
    let processor = ScaledElementProcessor()
    var albumTitles = [String]()
    
    
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        processor.process(in: imageView) { (text) in
            self.albumTitles = text.components(separatedBy: "\n")
        }
    }
    
    // MARK: - Location Methods
    
    
    
    // MARK: - Private Methods
    

    
    // MARK: - Navigation
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! AlbumTitlesVC
        vc.albumTitles = self.albumTitles
    }
    
    
    // MARK: - Action Methods
    
    @IBAction func searchSpotifyTapped(_ sender: Any) {
        
    }
    
}


    // MARK: - Extensions


