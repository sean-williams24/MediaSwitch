//
//  ScaledElementProcessor.swift
//  CDSaver
//
//  Created by Sean Williams on 12/02/2020.
//  Copyright © 2020 Sean Williams. All rights reserved.
//

import Firebase
import UIKit

class ScaledElementProcessor {
    
    // MARK: - Outlets

    
    
    // MARK: - Properties
    
    let vision = Vision.vision()
    var textRecognizer: VisionTextRecognizer!
    
    init() {
        textRecognizer = vision.onDeviceTextRecognizer()
    }
    
    
    
    // MARK: - Private Methods
    
    func process(in imageView: UIImageView, callback: @escaping (_ text: String, _ result: VisionText?) -> Void) {
      guard let image = imageView.image else { return }
      
      let visionImage = VisionImage(image: image)
      // 3
      textRecognizer.process(visionImage) { result, error in
        // 4
        guard error == nil, let result = result, !result.text.isEmpty else {
            callback("", nil)
            return
        }
        // 5
        
        callback(result.text, result)
      }
    }

    
    // MARK: - Navigation
    
    
 
    
    // MARK: - Action Methods
    

}


    // MARK: - Extensions


