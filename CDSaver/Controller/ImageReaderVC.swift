//
//  ImageReaderVC.swift
//  CDSaver
//
//  Created by Sean Williams on 12/02/2020.
//  Copyright © 2020 Sean Williams. All rights reserved.
//

import Firebase
import UIKit

class ImageReaderVC: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    // MARK: - Outlets

    @IBOutlet var imageView: UIImageView!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var imageLibraryButton: UIButton!
    
    
    // MARK: - Properties
    
    let processor = ScaledElementProcessor()
    var albumTitles = [String]()
    
    
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = false
        

    }
    
    // MARK: - Location Methods
    
    
    
    // MARK: - Private Methods
    

    
    // MARK: - Navigation
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! AlbumTitlesVC
        vc.albumTitles = self.albumTitles
    }
    
    // MARK: - Image Picker Delegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        guard let image = info[.editedImage] as? UIImage else { return }
        
        imageView.image = image
    }
    
    // MARK: - Action Methods
    
    @IBAction func imageLibraryButtonTapped(_ sender: Any) {
        
    }
    
    @IBAction func cameraButtonTapped(_ sender: Any) {
        
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
        
        
    }
    
    @IBAction func extractAlbumsTapped(_ sender: Any) {
        albumTitles.removeAll()
        
        var tempAlbumArray: [String] = []
        var previousYPosition: CGFloat = 0
        
        processor.process(in: imageView) { (text, result) in
            guard let result = result else { return }
            
            for block in result.blocks {
                let albumName = block.text.withoutSpecialCharacters
                
                print(albumName)
                
                // Ensure string is not purely numeric
                if !albumName.isNumeric {
                    
                    if let topLeftPoint = block.cornerPoints?.first as? CGPoint {
                        print(topLeftPoint.y)
                        if previousYPosition == 0 {
                            // First result
                            previousYPosition = topLeftPoint.y
                            tempAlbumArray.append(albumName)
                            
                        } else {
                            // Second result and onward >>>
                            if topLeftPoint.y - previousYPosition < 50 {
                                // On the same disc
                                previousYPosition = topLeftPoint.y
                                
                                for tempAlbum in tempAlbumArray {
                                    let combinedStrings = tempAlbum + " " + albumName
                                    tempAlbumArray.insert(combinedStrings, at: 0)
                                }
                                tempAlbumArray.append(albumName)
                                
                            } else {
                                // New disc
                                // Add temp albums to global array (previous disc)
                                for tempAlbum in tempAlbumArray {
                                    self.albumTitles.append(tempAlbum)
                                }
                                
                                // clear temp array
                                tempAlbumArray.removeAll()
                                
                                // add first result on next disc to temp array and set Y position
                                tempAlbumArray.append(albumName)
                                previousYPosition = topLeftPoint.y
                            }
                        }
                    }
                }
            }
            for tempAlbum in tempAlbumArray {
                self.albumTitles.append(tempAlbum)
            }
            print("Extraction complete")
            self.performSegue(withIdentifier: "showAlbumTitles", sender: self)
            
        }
    }
    
    @IBAction func unwindAction(unwindSegue: UIStoryboardSegue) {
        
    }
}


    // MARK: - Extensions

extension String {
    var isNumeric: Bool {
        guard self.count > 0 else { return false }
        
        let legitCharacters: Set<Character> = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", " ", "-"]
        return Set(self).isSubset(of: legitCharacters)

    }
    
    var withoutSpecialCharacters: String {
        return self.components(separatedBy: CharacterSet.symbols).joined(separator: "")
    }
}


