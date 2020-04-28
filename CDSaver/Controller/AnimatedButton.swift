////
////  UIViewController + Extension.swift
////  CDSaver
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
    
    
}
