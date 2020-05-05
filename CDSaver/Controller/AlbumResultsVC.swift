//
//  SpotifyAlbumResultsCVC.swift
//  CDSaver
//
//  Created by Sean Williams on 08/04/2020.
//  Copyright © 2020 Sean Williams. All rights reserved.
//

import Alamofire
import FSPagerView
import Kingfisher
import StoreKit
import UIKit

class AlbumResultsVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, CAAnimationDelegate {
    
    // MARK: - Outlets
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var alternativeAlbumsView: UIView!
    @IBOutlet weak var alternativeAlbumsViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var infoViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var infoButton: RoundButton!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var spotifyButton: RoundButton!
    @IBOutlet weak var addAlbumsButton: UIView!
    @IBOutlet weak var deleteButton: RoundButton!
    @IBOutlet weak var pagerView: FSPagerView! {
        didSet {
            self.pagerView.register(PagerViewCell.self, forCellWithReuseIdentifier: "cell")
        }
    }
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var appleButton: UIImageView!
    @IBOutlet weak var addAlbumsLabel: UILabel!
    @IBOutlet weak var addAlbumsStackView: UIStackView!
    
    
    // MARK: - Properties
    
    var spotifyAlbumResults = [[SpotifyAlbum]]()
    var spotifyAlbumGroup = [SpotifyAlbum]()
    var appleAlbumResults = [[AppleMusicAlbum]]()
    var appleAlbumGroup = [AppleMusicAlbum]()
    var viewingAppleMusic: Bool!
    var failedAlbums: [String] = []
    var numberOfAlbumsAdded = 0
    private let sectionInsets = UIEdgeInsets(top: 0, left: 10.0, bottom: 15.0, right: 10.0)
    var itemsPerRow: CGFloat = 2
    let albumsViewHeight: CGFloat = 290
    var altAlbumsViewStartLocation: CGPoint!
    var originalPoint: CGPoint!
    let newInfoViewMinHeight: CGFloat = 0.0
    var newInfoViewMaxHeight: CGFloat = 110.0
    var albumResultsIndex: Int!
    var selectedAlbums: [IndexPath] = []
    var blurredEffect = UIVisualEffectView()
    var deleting: Bool! {
        didSet {
            deleteButton.isEnabled = deleting
            deleteButton.tintColor = deleting ? .red : .white
        }
    }
    var colourSets = [[CGColor]]()
    var currentColourSet = 0
    var gradientLayer = CAGradientLayer()
    var colourTimer = Timer()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.contentInsetAdjustmentBehavior = .never
        alternativeAlbumsView.backgroundColor = .clear
        alternativeAlbumsViewHeightConstraint.constant = 0
        infoViewHeightConstraint.constant = 0
        collectionView.allowsMultipleSelection = true
        infoView.layer.borderWidth = 0.8
        
        pagerView.transformer = FSPagerViewTransformer(type: .linear)
        let width = view.frame.width / 2
        pagerView.itemSize = CGSize(width: width, height: width)
        pagerView.isUserInteractionEnabled = true
        pagerView.backgroundColor = UIColor.black.withAlphaComponent(0.9)
        pagerView.interitemSpacing = 60
        //        pagerView.layer.cornerRadius = 10
        //        pagerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        let dismissSwipe = UIPanGestureRecognizer(target: self, action: #selector(handleAltAlbumsViewSwipe))
        alternativeAlbumsView.addGestureRecognizer(dismissSwipe)
        
        let dismissTap = UITapGestureRecognizer(target: self, action: #selector(dismissAltAlbumsView))
        blurredEffect.addGestureRecognizer(dismissTap)
        blurredEffect.effect = nil
        blurredEffect.alpha = 0.9
        view.addSubview(blurredEffect)
        blurredEffect.translatesAutoresizingMaskIntoConstraints = false
        blurredEffect.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        blurredEffect.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        blurredEffect.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        blurredEffect.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        blurredEffect.isHidden = true
        
        deleting = false
        addAlbumsButton.alpha = 0
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(addAlbumsButtonTapped))
        addAlbumsButton.addGestureRecognizer(tapGesture)
        
        var musicService = ""
        
        if viewingAppleMusic {
            spotifyButton.isHidden = true
            infoButton.layer.cornerRadius = 12
            deleteButton.layer.cornerRadius = 12
            infoButton.tintColor = .systemPink
            
            let appleButtonTap = UITapGestureRecognizer(target: self, action: #selector(openCloseDropDownView))
            appleButton.addGestureRecognizer(appleButtonTap)
            appleButton.isUserInteractionEnabled = true
            
            colourSets = createColorSets()

            gradientLayer.frame = CGRect(x: 0, y: 0, width: addAlbumsButton.frame.width - 38, height: addAlbumsButton.frame.height)
            gradientLayer.cornerRadius = 30
            gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
            gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
            gradientLayer.colors = colourSets[currentColourSet]
            addAlbumsButton.layer.addSublayer(gradientLayer)
            addAlbumsButton.bringSubviewToFront(addAlbumsStackView)
            addAlbumsLabel.textColor = .white
            musicService = "Apple Music"
            
            logoImageView.isHidden = true
            addAlbumsLabel.text = "Add albums to Apple Music"
            addAlbumsButton.backgroundColor = .clear

            if traitCollection.userInterfaceStyle == .dark {
                appleButton.image = UIImage(named: "Apple_Music_Icon")
                
            } else {
                appleButton.image = UIImage(named: "Apple_Music_Icon_blk")
            }
                        
        } else {
            addAlbumsButton.backgroundColor = Style.Colours.spotifyGreen
            addAlbumsButton.layer.cornerRadius = 30
            appleButton.isHidden = true
            infoButton.layer.cornerRadius = 30
            deleteButton.layer.cornerRadius = 30
            musicService = "Spotify"
        }
        
        let attributedInfoText = NSMutableAttributedString(string: """
            - Tap + button to choose from alternative options
            - Tap albums to delete
            - Tap \(musicService) button to add albums to library
            """)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 8
        paragraphStyle.alignment = .left
        attributedInfoText.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: 60))
        infoLabel.attributedText = attributedInfoText
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if viewingAppleMusic {
            animateColours()
            colourTimer = Timer.scheduledTimer(timeInterval: 4.5, target: self, selector: #selector(animateColours), userInfo: nil, repeats: true)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if viewingAppleMusic {
            colourTimer.invalidate()
        }
    }
    
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if viewingAppleMusic {
            if traitCollection.userInterfaceStyle == .dark {
                appleButton.image = UIImage(named: "Apple_Music_Icon")
                addAlbumsStackView.backgroundColor = .white
                
            } else {
                appleButton.image = UIImage(named: "Apple_Music_Icon_blk")
                addAlbumsStackView.backgroundColor = .black
                
            }
        }
    }
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    
    // MARK: - Private Methods
    
    @objc func animateColours() {
        if currentColourSet < colourSets.count - 1 {
            currentColourSet += 1
        } else {
            currentColourSet = 0
        }
        
        let colourChangeAnimation = CABasicAnimation(keyPath: "colors")
        colourChangeAnimation.duration = 1.5
        colourChangeAnimation.toValue = colourSets[currentColourSet]
        colourChangeAnimation.fillMode = .forwards
        colourChangeAnimation.isRemovedOnCompletion = false
        colourChangeAnimation.delegate = self
        gradientLayer.add(colourChangeAnimation, forKey: "colorChange")
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag {
            gradientLayer.colors = colourSets[currentColourSet]
        }
    }
    
    fileprivate func showBlurredFXView(_ showBlur: Bool) {
        
        if showBlur {
            blurredEffect.isHidden = false
            view.bringSubviewToFront(alternativeAlbumsView)
            
            UIView.animate(withDuration: 0.4) {
                let blurFX = UIBlurEffect(style: .systemThickMaterialDark)
                self.blurredEffect.effect = blurFX
            }
        } else {
            UIView.animate(withDuration: 0.2, animations: {
                self.blurredEffect.effect = nil
            }) { _ in
                self.blurredEffect.isHidden = true
            }
        }
    }
    
    @objc func dismissAltAlbumsView() {
        alternativeAlbumsViewHeightConstraint.constant = 0
        UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseInOut, animations: {
            self.view.layoutIfNeeded()
        })
        showBlurredFXView(false)
    }
    
    
    @objc func handleAltAlbumsViewSwipe(_ gesture: UIPanGestureRecognizer) {
        
        let swipeDistancePoint = gesture.translation(in: view)
        
        guard let albumsView = gesture.view else { return }
        let newYPointToSet = albumsView.center.y + swipeDistancePoint.y
        
        switch gesture.state {
        case .began:
            print("")
            
        case .changed:
            if newYPointToSet <= originalPoint.y {
                return
            } else {
                albumsView.center = CGPoint(x: albumsView.center.x, y: newYPointToSet)
                gesture.setTranslation(.zero, in: view)
            }
            
        case .ended:
            let midPoint = originalPoint.y + (albumsViewHeight / 2)
            if newYPointToSet > midPoint {
                alternativeAlbumsViewHeightConstraint.constant = 0
                UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseInOut, animations: {
                    self.view.layoutIfNeeded()
                })
                
                showBlurredFXView(false)
                
            } else {
                UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseInOut, animations: {
                    albumsView.center = CGPoint(x: albumsView.center.x, y: self.originalPoint.y)
                })
            }
            
        default:
            break
        }
    }
    
    fileprivate func animateDropDownView() {
        if infoViewHeightConstraint.constant == newInfoViewMinHeight {
            self.infoViewHeightConstraint.constant = newInfoViewMaxHeight
        } else {
            self.infoViewHeightConstraint.constant = newInfoViewMinHeight
        }
        
        UIView.animate(withDuration: 0.4) {
            self.view.layoutIfNeeded()
        }
    }
    
    
    @objc fileprivate func openCloseDropDownView() {
        if infoViewHeightConstraint.constant == newInfoViewMinHeight {
            infoLabel.isHidden = true
            UIView.animate(withDuration: 0.4) {
                self.logoImageView.transform = CGAffineTransform(scaleX: 1, y: 1)
                self.addAlbumsButton.alpha = 1
            }
            animateDropDownView()
        } else if infoViewHeightConstraint.constant != newInfoViewMinHeight && infoLabel.isHidden == false {
            self.infoViewHeightConstraint.constant = newInfoViewMinHeight
            UIView.animate(withDuration: 0.4, animations: {
                self.view.layoutIfNeeded()
            }) { _ in
                self.infoLabel.isHidden = true
                UIView.animate(withDuration: 0.4) {
                    self.logoImageView.transform = CGAffineTransform(scaleX: 1, y: 1)
                    self.addAlbumsButton.alpha = 1
                }
                self.animateDropDownView()
            }
        } else {
            UIView.animate(withDuration: 0.2, animations: {
                self.logoImageView.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
                self.addAlbumsButton.alpha = 0
            }) { _ in
            }
            self.animateDropDownView()
        }
    }
    
    fileprivate func addAlbumsToSpotifyLibrary() {
        let accessToken = UserDefaults.standard.string(forKey: "access-token-key") ?? "NO_ACCESS_TOKEN"
        
        var index = 0
        let totalAlbums = spotifyAlbumResults.count
        for albumCollection in self.spotifyAlbumResults {
            if let album = albumCollection.first {
                let addAlbumsURL = "https://api.spotify.com/v1/me/albums?ids=\(album.id)"
                
                AF.request(addAlbumsURL, method: .put, parameters: ["ids": album.id], encoding: URLEncoding.default, headers: ["Authorization": "Bearer "+accessToken]).response { (response) in
                    
                    switch response.result {
                    case .success:
                        if let statusCode = response.response?.statusCode {
                            if statusCode == 200 {
                                print("\(album.name) Added to spotify")
                                self.numberOfAlbumsAdded += 1
                                index += 1
                                
                            } else {
                                print("\(album.name) failed to add")
                                if let artist = album.artists.first {
                                    self.failedAlbums.append("\(artist.name) - \(album.name)")
                                } else {
                                    self.failedAlbums.append(album.name)
                                }
                                index += 1
                            }
                        }
                        
                    case .failure:
                        self.blurredEffect.isUserInteractionEnabled = true
                        self.showAlert(title: "Connection Failed", message: "Your Internet connnection appears to be offline. Please connect and try again.") {
                            self.showBlurredFXView(false)
                        }
                    }
                    
                    if index == totalAlbums {
                        print("Completion")
                        self.performSegue(withIdentifier: "addAlbumsCompletion", sender: self)
                    }
                }
            }
        }
    }
    
    
    func addAlbumsToAppleMusicLibrary() {
        let userToken = Auth.Apple.userToken
        var index = 0

        for albumCollection in appleAlbumResults {
            if let album = albumCollection.first {
                let addAlbumsURL = "https://api.music.apple.com/v1/me/library?ids[albums]=\(album.id)"
                
                AF.request(addAlbumsURL, method: .post, parameters: ["ids[albums]": album.id], encoding: URLEncoding.default, headers: ["Music-User-Token": userToken, "Authorization": "Bearer " + Auth.Apple.developerToken]).response { response in
                    
                    switch response.result {
                    case .success:
                        if response.response?.statusCode == 202 {
                                print("\(album.attributes.name) added to Apple Music library")
                                self.numberOfAlbumsAdded += 1
                                index += 1
                            } else {
                                print("\(album.attributes.name) failed to add")
                                self.failedAlbums.append("\(album.attributes.artistName) - \(album.attributes.name)")
                                
                                index += 1
                            }
                    case .failure:
                        self.blurredEffect.isUserInteractionEnabled = true
                        self.showAlert(title: "Connection Failed", message: "Your Internet connnection appears to be offline. Please connect and try again.") {
                            self.showBlurredFXView(false)
                        }
                    }
                    
                    if index == self.appleAlbumResults.count {
                        print("Completion")
                        self.performSegue(withIdentifier: "addAlbumsCompletion", sender: self)
                    }
                }
            }
        }
    }
    
    @objc func addAlbumsButtonTapped() {
        showBlurredFXView(true)
        blurredEffect.isUserInteractionEnabled = false
        
        viewingAppleMusic ? addAlbumsToAppleMusicLibrary() : addAlbumsToSpotifyLibrary()
    }
    
    
    // MARK: - Action Methods
    
    @IBAction func alternativeAlbumsButtonTapped(_ sender: UIButton) {
        pagerView.selectItem(at: 0, animated: true)
        showBlurredFXView(true)
        
        if viewingAppleMusic {
            appleAlbumGroup = appleAlbumResults[sender.tag]
        } else {
            spotifyAlbumGroup = spotifyAlbumResults[sender.tag]
        }
        albumResultsIndex = sender.tag
        pagerView.reloadData()
        
        alternativeAlbumsViewHeightConstraint.constant = alternativeAlbumsViewHeightConstraint.constant == albumsViewHeight ? 0 : albumsViewHeight
        UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseInOut, animations: {
            self.view.layoutIfNeeded()
        }) { _ in
            self.originalPoint = self.alternativeAlbumsView.center
        }
    }
    
    
    @IBAction func infoButtonTapped(_ sender: Any) {
        if infoViewHeightConstraint.constant == newInfoViewMinHeight {
            addAlbumsButton.alpha = 0
            infoLabel.isHidden = false
            animateDropDownView()
        } else if infoViewHeightConstraint.constant != newInfoViewMinHeight && infoLabel.isHidden == true {
            self.infoViewHeightConstraint.constant = newInfoViewMinHeight
            UIView.animate(withDuration: 0.4, animations: {
                self.view.layoutIfNeeded()
            }) { _ in
                UIView.animate(withDuration: 0.2, animations: {
                    self.logoImageView.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
                    self.addAlbumsButton.alpha = 0
                }) { _ in
                    
                }
                self.infoLabel.isHidden = false
                self.animateDropDownView()
            }
        } else {
            animateDropDownView()
        }
    }
    
    
    @IBAction func spotifyButtonTapped(_ sender: Any) {
        openCloseDropDownView()
    }
    
    
    @IBAction func deleteButtonTapped(_ sender: Any) {
        
        for indexPath in selectedAlbums.sorted().reversed() {
            if viewingAppleMusic {
                appleAlbumResults.remove(at: indexPath.item)
            } else {
                spotifyAlbumResults.remove(at: indexPath.item)
            }
        }
        
        self.collectionView.performBatchUpdates({
            self.collectionView.deleteItems(at: selectedAlbums)
        }) { _ in
            self.selectedAlbums.removeAll()
            self.collectionView.reloadData()
            self.deleting = !self.selectedAlbums.isEmpty
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! AlbumsAddedVC
        vc.failedAlbums = self.failedAlbums
        vc.numberOfAlbumsAdded = self.numberOfAlbumsAdded
        vc.viewingAppleMusic = viewingAppleMusic
    }
    
    
    // MARK: - UICollectionViewDataSource + Delegate
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return viewingAppleMusic ? appleAlbumResults.count : spotifyAlbumResults.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "albumCell", for: indexPath) as! AlbumCVCell
        cell.imageView.backgroundColor = .white
        
        var albumArtworkURLString = ""
        
        if viewingAppleMusic {
            let appleMusicAlbumGroup = appleAlbumResults[indexPath.item]
            if !appleMusicAlbumGroup.isEmpty {
                let firstAlbum = appleMusicAlbumGroup[0].attributes
                let url = firstAlbum.artwork.url
                albumArtworkURLString = String(url.dropLast(14))
                albumArtworkURLString.append("400x400bb.jpeg")
                
                if appleMusicAlbumGroup.count == 1 {
                    cell.alternativesButtonView.isHidden = true
                } else {
                    cell.alternativesButtonView.isHidden = false
                }
                
                cell.albumTitleTextLabel.text = firstAlbum.name
                cell.artistTextLabel.text = firstAlbum.artistName
            }
            
        } else {
            let spotifyAlbumGroup = spotifyAlbumResults[indexPath.item]
            if !spotifyAlbumGroup.isEmpty {
                let firstAlbum = spotifyAlbumGroup[0]
                albumArtworkURLString = firstAlbum.images[0].url
                
                if spotifyAlbumGroup.count == 1 {
                    cell.alternativesButtonView.isHidden = true
                } else {
                    cell.alternativesButtonView.isHidden = false
                }
                
                cell.albumTitleTextLabel.text = firstAlbum.name
                cell.artistTextLabel.text = firstAlbum.artists[0].name
            }
        }
        
        cell.alternativesButton.tag = indexPath.item
        
        // Download and cahce album cover image
        let imageURL = URL(string: albumArtworkURLString)
        cell.imageView.kf.setImage(with: imageURL)
        
        let processor = DownsamplingImageProcessor(size: cell.imageView.bounds.size)
            |> RoundCornerImageProcessor(cornerRadius: 3)
        
        cell.imageView.kf.indicatorType = .activity
        cell.imageView.kf.setImage(
            with: imageURL,
            placeholder: UIImage(named: "placeholderImage"),
            options: [
                .processor(processor),
                .scaleFactor(UIScreen.main.scale),
                .transition(.flipFromLeft(1)),
                .cacheOriginalImage
            ])
        {
            result in
            switch result {
            case .success:
//                print("Task done for: \(value.source.url?.absoluteString ?? "")")
                print("")
            case .failure(let error):
                print("Job failed: \(error.localizedDescription)")
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        deleting = true
        selectedAlbums.append(indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        selectedAlbums.removeAll(where: {$0 == indexPath})
        deleting = !selectedAlbums.isEmpty
        
    }
    
    
    // MARK: - UICollectionViewFlowDelegate
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: widthPerItem + 47)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        sectionInsets.left
    }
}


// MARK: - Alternative Albums Menu

extension AlbumResultsVC: FSPagerViewDelegate, FSPagerViewDataSource {
    
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        return viewingAppleMusic ? appleAlbumGroup.count : spotifyAlbumGroup.count
    }
    
    
    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "cell", at: index) as! PagerViewCell
        
        var albumCoverString = ""
        if viewingAppleMusic {
            let album = appleAlbumGroup[index]
            albumCoverString = album.attributes.artwork.url
            albumCoverString = String(albumCoverString.dropLast(14))
            albumCoverString.append("400x400bb.jpeg")
            cell.albumTitleLabel?.text = album.attributes.name
        } else {
            let album = spotifyAlbumGroup[index]
            albumCoverString = album.images[0].url
            cell.albumTitleLabel?.text = album.name
        }
        
        // Download and cache album cover image
        let imageURL = URL(string: albumCoverString)
        cell.imageView?.kf.setImage(with: imageURL)
        cell.imageView?.contentMode = .scaleAspectFit
        cell.imageView?.layer.cornerRadius = 3
        
        return cell
    }
    
    func pagerView(_ pagerView: FSPagerView, shouldHighlightItemAt index: Int) -> Bool {
        return true
    }
    
    func pagerView(_ pagerView: FSPagerView, shouldSelectItemAt index: Int) -> Bool {
        return true
    }
    
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        
        alternativeAlbumsViewHeightConstraint.constant = 0
        UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseInOut, animations: {
            self.view.layoutIfNeeded()
        })
        
        showBlurredFXView(false)
        
        if viewingAppleMusic {
            let chosenAlbum = appleAlbumGroup[index]
            for (i, album) in appleAlbumGroup.enumerated().reversed() {
                if album.id == chosenAlbum.id {
                    appleAlbumGroup.remove(at: i)
                    appleAlbumGroup.insert(chosenAlbum, at: 0)
                    
                    appleAlbumResults.remove(at: albumResultsIndex)
                    appleAlbumResults.insert(appleAlbumGroup, at: albumResultsIndex)
                    collectionView.reloadItems(at: [IndexPath(item: albumResultsIndex, section: 0)])
                }
            }
        } else {
            let chosenAlbum = spotifyAlbumGroup[index]
            for (i, album) in spotifyAlbumGroup.enumerated().reversed() {
                if album.id == chosenAlbum.id {
                    spotifyAlbumGroup.remove(at: i)
                    spotifyAlbumGroup.insert(chosenAlbum, at: 0)
                    
                    spotifyAlbumResults.remove(at: albumResultsIndex)
                    spotifyAlbumResults.insert(spotifyAlbumGroup, at: albumResultsIndex)
                    collectionView.reloadItems(at: [IndexPath(item: albumResultsIndex, section: 0)])
                }
            }
        }
    }
}


// MARK: - ScrollView Delegates

extension AlbumResultsVC: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y
        let newInfoViewHeight = infoViewHeightConstraint.constant - offset
        
        //        if newInfoViewHeight < newInfoViewMinHeight {
        //            infoViewHeightConstraint.constant = newInfoViewMinHeight
        //        } else if newInfoViewHeight > newInfoViewMaxHeight {
        //            infoViewHeightConstraint.constant = newInfoViewMaxHeight
        //        } else {
        //            infoViewHeightConstraint.constant = newInfoViewHeight
        //            scrollView.contentOffset.y = 0.0
        //        }
    }
    
    //     func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    //
    //     if(velocity.y>0) {
    //        UIView.animate(withDuration: 0.5, delay: 0, options: UIView.AnimationOptions(), animations: {
    //             self.navigationController?.setNavigationBarHidden(true, animated: true)
    //         }, completion: nil)
    //
    //     } else {
    //        UIView.animate(withDuration: 0.5, delay: 0, options: UIView.AnimationOptions(), animations: {
    //            self.navigationController?.setNavigationBarHidden(false, animated: true)
    //        }, completion: nil)
    //        }
    //    }
    
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        //        if infoViewHeightConstraint.constant < (newInfoViewMaxHeight / 2) {
        //            self.infoViewHeightConstraint.constant = self.newInfoViewMinHeight
        //        } else {
        //            self.infoViewHeightConstraint.constant = self.newInfoViewMaxHeight
        //        }
        if infoViewHeightConstraint.constant != newInfoViewMinHeight {
            infoViewHeightConstraint.constant = newInfoViewMinHeight
        }
        
        UIView.animate(withDuration: 0.4, animations: {
            self.logoImageView.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
            self.addAlbumsButton.alpha = 0
            self.view.layoutIfNeeded()
            
        }) { _ in
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if infoViewHeightConstraint.constant != newInfoViewMinHeight {
            infoViewHeightConstraint.constant = newInfoViewMinHeight
        }
        
        UIView.animate(withDuration: 0.4, animations: {
            self.logoImageView.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
            self.addAlbumsButton.alpha = 0
            self.view.layoutIfNeeded()
            
        }) { _ in
            
        }
    }
    
}

extension String {
    
}
