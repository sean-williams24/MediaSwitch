//
//  ImageReaderVC.swift
//  CDSaver
//
//  Created by Sean Williams on 12/02/2020.
//  Copyright © 2020 Sean Williams. All rights reserved.
//

import Firebase
import UIKit
import QCropper

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
        vc.albumTitles = self.albumTitles.removingDuplicates()
    }
    
    // MARK: - Image Picker Delegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else { return }

        let cropper = CropperViewController(originalImage: image)
        cropper.delegate = self

        picker.dismiss(animated: true) {
            self.present(cropper, animated:  true)
        }
        
        imageView.image = image
    }
    
    // MARK: - Action Methods
    
    @IBAction func imageLibraryButtonTapped(_ sender: Any) {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = false
        
        present(vc, animated: true)
    }
    
    @IBAction func cameraButtonTapped(_ sender: Any) {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        vc.allowsEditing = false
        vc.showsCameraControls = true
        vc.cameraCaptureMode = .photo
        
        present(vc, animated: true)
    }
    
    @IBAction func extractAlbumsTapped(_ sender: Any) {
        albumTitles.removeAll()
        
        var tempAlbumArray: [String] = []
        var previousYPosition: CGFloat = 0
        
        processor.process(in: imageView) { (text, result) in
            guard let result = result else {
                print("No titles?")
                // SHOW ALERT
                return
            }
//            print(text)
            for block in result.blocks {
                var albumName = block.text.withoutSpecialCharacters
                print("")
                print("BLOCK TEXT RESULT: \(albumName)")
                
                if albumName.contains("\n") {
                    print("Contains multi line")
                    var blockArray = albumName.components(separatedBy: "\n")
                    print(blockArray)
                    blockArray.removeDuplicates()
                    albumName = blockArray.joined(separator: " ")
                    print(albumName)
                }
                

                // Ensure string is not purely numeric
                if !albumName.isNumeric {
                    
//                    self.albumTitles.append(albumName)
                    
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
//                                    print(tempAlbum)
//                                    print(albumName)
//                                    print(combinedStrings)

                                    tempAlbumArray.insert(combinedStrings, at: 0)
                                }
//                                tempAlbumArray.append(contentsOf: secondTempAlbumArray)
                                tempAlbumArray.append(albumName)
                                print(tempAlbumArray)

                            } else {
                                // New disc
                                // Add temp albums to global array (previous disc)
                                self.albumTitles += tempAlbumArray

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
            self.albumTitles += tempAlbumArray
            print("Extraction complete")

            self.performSegue(withIdentifier: "showAlbumTitles", sender: self)
            
        }
    }
    
    @IBAction func unwindAction(unwindSegue: UIStoryboardSegue) {
        
    }
}


    // MARK: - Extensions

extension ImageReaderVC: CropperViewControllerDelegate {
    
        func cropperDidConfirm(_ cropper: CropperViewController, state: CropperState?) {
            cropper.dismiss(animated: true, completion: nil)

            if let state = state,
                let image = cropper.originalImage.cropped(withCropperState: state) {
    //            cropperState = state
                imageView.image = image
//                print(cropper.isCurrentlyInInitialState)
//                print(image)
            }
        }
}

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

extension Array where Element: Hashable {
    func removingDuplicates() -> [Element] {
        var addedDict = [Element: Bool]()
        
        return filter {
            addedDict.updateValue(true, forKey: $0) == nil
        }
    }
    
    mutating func removeDuplicates() {
        self = self.removingDuplicates()
    }
}


