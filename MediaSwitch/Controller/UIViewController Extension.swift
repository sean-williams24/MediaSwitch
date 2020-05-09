////
////  UIViewController + Extension.swift
////  MediaSwitch
////
////  Created by Sean Williams on 28/04/2020.
////  Copyright © 2020 Sean Williams. All rights reserved.
////
//
import Foundation

extension UIViewController {

     func createColorSets() -> [[CGColor]] {
         var colourSets: [[CGColor]] = []
         colourSets.append([UIColor.systemPink.cgColor, UIColor.systemBlue.cgColor])
         colourSets.append([UIColor.systemPurple.cgColor, UIColor.systemPink.cgColor])
         colourSets.append([UIColor.systemBlue.cgColor, UIColor.systemPink.cgColor])
      
         return colourSets
     }
    
    //MARK: - Universal Alert Controller
     
     func showAlert(title: String, message: String?) {
         DispatchQueue.main.async {
             let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
             ac.addAction(UIAlertAction(title: "OK", style: .default))
             self.present(ac, animated: true)
         }
     }
    
    func showAlert(title: String, message: String?, completion: @escaping () -> ()) {
        DispatchQueue.main.async {
            let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)            
            ac.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                completion()
                print("OK tapped")
            }))
            
            self.present(ac, animated: true)
        }
    }
    
}
