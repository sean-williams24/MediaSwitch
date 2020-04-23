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
    @IBOutlet weak var blurredEffectView: UIVisualEffectView!
    @IBOutlet weak var coverButtonView: UIView!
    @IBOutlet weak var coverButton: UIButton!
    @IBOutlet weak var buttonStack: UIStackView!
    @IBOutlet weak var albumStackView: UIView!
    @IBOutlet weak var stackButton: UIButton!
    
    
    // MARK: - Properties
    
    let processor = ScaledElementProcessor()
    var albumTitles = [String]()
    let blurEffect = UIBlurEffect(style: .systemChromeMaterialDark)
    
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = false
        
        blurredEffectView.effect = nil
        let dismissTap = UITapGestureRecognizer(target: self, action: #selector(dismissBlurView))
        blurredEffectView.addGestureRecognizer(dismissTap)
        
        coverButtonView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        coverButtonView.layer.cornerRadius = 30
        albumStackView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        albumStackView.layer.cornerRadius = 30
        
//        blurredEffectView.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(blurredEffectView)
        
//        NSLayoutConstraint.activate([
//            blurredEffectView.heightAnchor.constraint(equalTo: view.heightAnchor),
//            blurredEffectView.widthAnchor.constraint(equalTo: view.widthAnchor),
//        ])
//
//        let label = UILabel()
//        label.text = "Extract from CD stack or album covers?"
//        label.font = UIFont(name: "HelveticaNeue-Regular", size: 18)
//        label.sizeToFit()
//        label.textColor = .white
//        label.center = view.center
//
//        let stackView = UIStackView()
//        stackView.alignment = .center
//        stackView.axis = .horizontal
//        stackView.distribution = .fillEqually
//        stackView.spacing = 10
        
//        let stackButton = UIButton()
//        stackButton.setBackgroundImage(UIImage(systemName: "square.stack.3d.up.fill"), for: .normal)
//        stackButton.backgroundColor = UIColor.black.withAlphaComponent(0.4)
////        stackButton.heightAnchor.constraint(equalToConstant: 130.0).isActive = true
////        stackButton.widthAnchor.constraint(equalToConstant: 130.0).isActive = true
////        stackButton.layer.cornerRadius = 30
//        stackButton.tintColor = .white
//        stackButton.addTarget(self, action: #selector(albumStackExtraction), for: .touchUpInside)
        
//        let stackButtonView = UIView()
//        stackButtonView.translatesAutoresizingMaskIntoConstraints = false
//        stackButtonView.heightAnchor.constraint(equalToConstant: 130.0).isActive = true
//        stackButtonView.widthAnchor.constraint(equalToConstant: 130.0).isActive = true
//        stackButtonView.layer.cornerRadius = 30
//        stackButtonView.addSubview(stackButton)
//        stackButton.topAnchor.constraint(equalTo: stackButtonView.topAnchor, constant: 10).isActive = true
//        stackButton.bottomAnchor.constraint(equalTo: stackButtonView.bottomAnchor, constant: 10).isActive = true
//        stackButton.leadingAnchor.constraint(equalTo: stackButtonView.leadingAnchor, constant: 10).isActive = true
//        stackButton.trailingAnchor.constraint(equalTo: stackButtonView.trailingAnchor, constant: 10).isActive = true


        
//        let coversButton = UIButton()
//        coversButton.setBackgroundImage(UIImage(systemName: "album"), for: .normal)
//        coversButton.titleLabel?.text = "Album Covers"
//        coversButton.setTitle("Album Covers", for: .normal)

        
//        stackView.addArrangedSubview(stackButtonView)
//        stackView.addArrangedSubview(coversButton)
//        stackView.translatesAutoresizingMaskIntoConstraints = false
        
//        let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect)
//        let vibrancyEffectView = UIVisualEffectView(effect: vibrancyEffect)
//        vibrancyEffectView.frame = view.bounds
//        vibrancyEffectView.contentView.addSubview(label)
        
//        blurredEffectView.contentView.addSubview(label)
//        blurredEffectView.contentView.addSubview(stackView)
        
//        NSLayoutConstraint.activate([
//            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0),
//            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0),
////            stackView.widthAnchor.constraint(lessThanOrEqualToConstant: 320),
////            stackView.heightAnchor.constraint(lessThanOrEqualToConstant: 160),
////            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
//            //            stackView.heightAnchor.constraint(equalToConstant: 300)
//        ])
        
        blurredEffectView.isHidden = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        blurredEffectView.effect = nil
        blurredEffectView.isHidden = true
        blurredEffectView.isUserInteractionEnabled = true
    }

    // MARK: - Private Methods
    
    @objc func dismissBlurView() {
        UIView.animate(withDuration: 0.3, animations: {
            self.blurredEffectView.effect = nil
            self.buttonStack.alpha = 0
        }) { _ in
            self.blurredEffectView.isHidden = true
        }
    }
    
    @IBAction func albumCoverExtraction() {
        blurredEffectView.isUserInteractionEnabled = false
        albumTitles.removeAll()
        
        processor.process(in: imageView) { (text, result) in
            guard let result = result else {
                // Show alert
                return
            }
            
            for block in result.blocks {
                var albumName = block.text.withoutSpecialCharacters
                
                if albumName.contains("\n") {
                    var blockArray = albumName.components(separatedBy: "\n")
                    blockArray.removeDuplicates()
                    albumName = blockArray.joined(separator: " ")
                }
                
                if !albumName.isNumeric {
                    self.albumTitles.append(albumName)
                }
            }
            self.performSegue(withIdentifier: "showAlbumTitles", sender: self)
        }
    }
    
    
    @IBAction func albumStackExtraction() {
        blurredEffectView.isUserInteractionEnabled = false
        albumTitles.removeAll()
        
        var tempAlbumArray: [String] = []
        var previousYPosition: CGFloat = 0
        
        processor.process(in: imageView) { (text, result) in
            guard let result = result else {
                print("No titles?")
                // SHOW ALERT
                return
            }
            
            for block in result.blocks {
                var albumName = block.text.withoutSpecialCharacters
                
                if albumName.contains("\n") {
                    var blockArray = albumName.components(separatedBy: "\n")
                    blockArray.removeDuplicates()
                    albumName = blockArray.joined(separator: " ")
                }
                
                // Ensure string is not purely numeric
                if !albumName.isNumeric {
                    if let topLeftPoint = block.cornerPoints?.first as? CGPoint {
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
//        blurredEffectView.alpha = 1
        blurredEffectView.isHidden = false
        UIView.animate(withDuration: 0.4) {
//            self.blurredEffectView.alpha = 1
            self.blurredEffectView.effect = self.blurEffect
            self.buttonStack.alpha = 1
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


