//
//  ImageReaderVC.swift
//  CDSaver
//
//  Created by Sean Williams on 12/02/2020.
//  Copyright © 2020 Sean Williams. All rights reserved.
//

import Firebase
import NVActivityIndicatorView
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
    @IBOutlet weak var activityView: NVActivityIndicatorView!
    @IBOutlet weak var labelsStackView: UIStackView!
    @IBOutlet weak var extractAlbumsButton: RoundButton!
    @IBOutlet weak var infoEffectsView: UIVisualEffectView!
    @IBOutlet weak var infoVibrancyContentView: UIView!
    
    
    // MARK: - Properties
    
    let processor = ScaledElementProcessor()
    var albumTitles = [String]()
    let blurEffect = UIBlurEffect(style: .prominent)
    var viewingAppleMusic: Bool!
    var spotifyAlbums: [[SpotifyAlbum]] = []
    var appleMusicAlbums: [[AppleMusicAlbum]] = []

    
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
        blurredEffectView.isHidden = true
        
        let buttonTint = viewingAppleMusic ? UIColor.systemPink : Style.Colours.spotifyGreen
        
        cameraButton.tintColor = buttonTint
        imageLibraryButton.tintColor = buttonTint
        stackButton.tintColor = buttonTint
        coverButton.tintColor = buttonTint
        navigationController?.navigationBar.tintColor = buttonTint
        
        activityView.color = traitCollection.userInterfaceStyle == .dark ? .white : .black
        
        extractAlbumsButton.isEnabled = false
        extractAlbumsButton.setTitleColor(.darkGray, for: .disabled)
        extractAlbumsButton.setTitleColor(.white, for: .normal)
        
        infoEffectsView.layer.cornerRadius = 5
        infoVibrancyContentView.layer.cornerRadius = 5
        infoEffectsView.effect = nil       
        imageView.contentMode = .scaleAspectFill

        
        UIView.animate(withDuration: 3) {
            self.infoEffectsView.effect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        }
        
        infoEffectsView.translatesAutoresizingMaskIntoConstraints = false
        if UIDevice.current.userInterfaceIdiom == .pad {
            infoEffectsView.widthAnchor.constraint(equalToConstant: 450).isActive = true
        } else {
            infoEffectsView.widthAnchor.constraint(equalToConstant: view.frame.width - 20).isActive = true
        }
        
        
//        extractAlbumsButton.isEnabled = true
//        infoEffectsView.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
      
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        showLoadingActivity(false)
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
    
    fileprivate func showLoadingActivity(_ loading: Bool) {
        print("Show loading: \(loading)")
        if loading {
            blurredEffectView.isUserInteractionEnabled = false

            UIView.animate(withDuration: 0.5, animations: {
                self.coverButtonView.alpha = 0
                self.albumStackView.alpha = 0
                self.labelsStackView.alpha = 0
            }) { _ in
                self.coverButtonView.isHidden = true
                self.albumStackView.isHidden = true
                self.labelsStackView.isHidden = true
                self.activityView.alpha = 0
                self.activityView.isHidden = false
                self.activityView.startAnimating()
                UIView.animate(withDuration: 1.1, animations: {
                    self.activityView.alpha = 1
                }) { _ in
                    
                }
            }
        } else {
            UIView.animate(withDuration: 0.3, animations: {
                self.coverButtonView.alpha = 1
                self.albumStackView.alpha = 1
                self.labelsStackView.alpha = 1
                self.blurredEffectView.effect = nil
                self.activityView.alpha = 0

            }) { _ in
                self.blurredEffectView.isHidden = true
                self.blurredEffectView.isUserInteractionEnabled = true
                self.coverButtonView.isHidden = false
                self.albumStackView.isHidden = false
                self.labelsStackView.isHidden = false
                self.activityView.isHidden = true
            }

        }
    }
    
    @IBAction func albumCoverExtraction() {
        showLoadingActivity(true)
        albumTitles.removeAll()
        
        processor.process(in: imageView) { (text, result) in
            guard let result = result else {
                self.showAlert(title: "No Text Found In Image", message: "Please make sure the image is clear and the albums are aligned horizontally straight.") {
                    self.showLoadingActivity(false)
                }
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
//            self.albumTitles = ["axxhxhxhhxhjhxjjx"]
            if self.viewingAppleMusic {
                AlbumSearchClient.appleMusicAlbumSearch(with: self.albumTitles.removingDuplicates(), searchCompletion: self.handleAppleMusicSearchResponse(appleMusicAlbumResults:error:))
                
              } else {
                  AlbumSearchClient.spotifyAlbumSearch(with: self.albumTitles.removingDuplicates(), searchCompletion: self.handleSpotifySearchResponse(spotifyAlbumResults:error:))
              }
        }
    }
    
    
    @IBAction func albumStackExtraction() {
        showLoadingActivity(true)
        albumTitles.removeAll()
        
        var tempAlbumArray: [String] = []
        var previousYPosition: CGFloat = 0
        
        processor.process(in: imageView) { (text, result) in
            guard let result = result else {
                self.showAlert(title: "No Text Found In Image", message: "Please make sure the image is clear and the albums are aligned horizontally straight.") {
                    self.showLoadingActivity(false)
                }
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

//            self.albumTitles = ["\axxhxhxhhxhjhxjjx"]

            if self.viewingAppleMusic {
                
                AlbumSearchClient.appleMusicAlbumSearch(with: self.albumTitles.removingDuplicates(), searchCompletion: self.handleAppleMusicSearchResponse(appleMusicAlbumResults:error:))
                
            } else {
//                let albumSearcher = AlbumSearchClient()
//                albumSearcher.spotifyAlbumSearch(with: self.albumTitles.removingDuplicates()) { (spotifyAlbumResults) in
//                    self.spotifyAlbums = spotifyAlbumResults
//                    self.performSegue(withIdentifier: "showAlbums", sender: self)
//                }
                
                AlbumSearchClient.spotifyAlbumSearch(with: self.albumTitles.removingDuplicates(), searchCompletion: self.handleSpotifySearchResponse(spotifyAlbumResults:error:))
            }

        }
    }
    
    func handleAppleMusicSearchResponse(appleMusicAlbumResults: [[AppleMusicAlbum]], error: Error?) {
        guard error == nil else {
            self.showAlert(title: "Connection Failed", message: "Your Internet connnection appears to be offline. Please connect and try again.") {
                self.showLoadingActivity(false)
                return
            }
            return
        }
        
        if !appleMusicAlbumResults.isEmpty {
            self.appleMusicAlbums = appleMusicAlbumResults
            self.performSegue(withIdentifier: "showAlbums", sender: self)
        } else {
            self.showAlert(title: "Albums not found in Apple Music catalog", message: "Please make sure the image is clear and the albums are aligned horizontally straight.") {
                self.showLoadingActivity(false)
                return
            }
        }
    }
    
    func handleSpotifySearchResponse(spotifyAlbumResults: [[SpotifyAlbum]], error: Error?) {
        guard error == nil else {
            self.showAlert(title: "Connection Failed", message: "Your Internet connnection appears to be offline. Please connect and try again.") {
                self.showLoadingActivity(false)
                return
            }
            return
        }
        
        if !spotifyAlbumResults.isEmpty {
            self.spotifyAlbums = spotifyAlbumResults
            self.performSegue(withIdentifier: "showAlbums", sender: self)
        } else {
            self.showAlert(title: "Albums not found in Spotify catalog", message: "Please make sure the image is clear, the albums are aligned horizontally straight and you're connected to the Internet.") {
                self.showLoadingActivity(false)
                return
            }
        }
    }
    
    // MARK: - Navigation
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! AlbumResultsVC
//        vc.albumTitles = self.albumTitles.removingDuplicates()
        if viewingAppleMusic {
            vc.appleAlbumResults = appleMusicAlbums
            vc.viewingAppleMusic = true
        } else {
            vc.spotifyAlbumResults = spotifyAlbums
            vc.viewingAppleMusic = false
        }
        
    }
    
    // MARK: - Image Picker Delegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else { return }

        let cropper = CropperViewController(originalImage: image)
        cropper.delegate = self

        picker.dismiss(animated: true) {
            self.present(cropper, animated:  true)
        }
        
        infoEffectsView.isHidden = true
        imageView.contentMode = .scaleAspectFit
        imageView.image = image
        extractAlbumsButton.isEnabled = true
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
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            self.showAlert(title: "No Camera Detected", message: "Please use a device with a camera or add an image from your library.")
            return
        }
        
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        vc.allowsEditing = false
        vc.showsCameraControls = true
        vc.cameraCaptureMode = .photo
        
        present(vc, animated: true)
    }
    
    
    @IBAction func extractAlbumsTapped(_ sender: Any) {
//        showLoadingActivity(false)
        blurredEffectView.isHidden = false
        UIView.animate(withDuration: 0.4) {

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


