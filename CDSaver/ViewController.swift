//
//  ViewController.swift
//  CDSaver
//
//  Created by Sean Williams on 12/02/2020.
//  Copyright © 2020 Sean Williams. All rights reserved.
//

import Firebase
import UIKit

class ViewController: UIViewController {
    
    // MARK: - Outlets

    @IBOutlet var imageView: UIImageView!
    
    
    // MARK: - Properties
    
    let processor = ScaledElementProcessor()
    
    
    
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        processor.process(in: imageView) { (text) in
            print(text)
        }
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        

    }
    
    
    // MARK: - Location Methods
    
    
    
    // MARK: - Private Methods
    

    
    // MARK: - Navigation
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    
    
    // MARK: - Action Methods
    

}


    // MARK: - Extensions


