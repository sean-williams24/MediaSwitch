//
//  ScaledElementProcessor.swift
//  MediaSwitch
//
//  Created by Sean Williams on 12/02/2020.
//  Copyright © 2020 Sean Williams. All rights reserved.
//

import Firebase
import UIKit

class ScaledElementProcessor {

    
    // MARK: - Properties
    
    let vision = Vision.vision()
    var textRecognizer: VisionTextRecognizer!
    
    init() {
        textRecognizer = vision.cloudTextRecognizer()
    }
    
    
    
    // MARK: - Private Methods
    
    func process(in imageView: UIImageView, callback: @escaping (_ text: String, _ result: VisionText?) -> Void) {
      guard let image = imageView.image else { return }
      
      let visionImage = VisionImage(image: image)
      
      textRecognizer.process(visionImage) { result, error in
        
        guard error == nil, let result = result, !result.text.isEmpty else {
            callback("", nil)
            return
        }
        
        callback(result.text, result)
      }
    }
}
