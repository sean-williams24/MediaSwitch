//
//  SpotifyAlbumResultsCVC.swift
//  CDSaver
//
//  Created by Sean Williams on 08/04/2020.
//  Copyright © 2020 Sean Williams. All rights reserved.
//

import FSPagerView
import Kingfisher
import UIKit

class SpotifyAlbumResultsCVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // MARK: - Outlets
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var alternativeAlbumsView: UIView!
    @IBOutlet weak var alternativeAlbumsViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var pagerView: FSPagerView! {
        didSet {
            self.pagerView.register(PagerViewCell.self, forCellWithReuseIdentifier: "cell")
        }
    }
    
    
    // MARK: - Properties
    
    var albumResults = [[Album]]()
    var albumGroup = [Album]()
    private let sectionInsets = UIEdgeInsets(top: 15.0, left: 10.0, bottom: 15.0, right: 10.0)
    var itemsPerRow: CGFloat = 2
    let albumsViewHeight: CGFloat = 290
    var altAlbumsViewStartLocation: CGPoint!
    var originalPoint: CGPoint!
    
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.contentInsetAdjustmentBehavior = .never
        alternativeAlbumsView.backgroundColor = .clear
        alternativeAlbumsViewHeightConstraint.constant = 0
        
        pagerView.transformer = FSPagerViewTransformer(type: .linear)
        let width = view.frame.width / 2
        pagerView.itemSize = CGSize(width: width, height: width)
        pagerView.isUserInteractionEnabled = true
        pagerView.backgroundColor = UIColor.black.withAlphaComponent(0.9)
        pagerView.interitemSpacing = 60
        pagerView.layer.cornerRadius = 10
        pagerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        let dismissSwipe = UIPanGestureRecognizer(target: self, action: #selector(dismissAlternativeAlbumsView))
        alternativeAlbumsView.addGestureRecognizer(dismissSwipe)
        
//        print(albumResults[0])
        
//        if albumResults[0].isEmpty {
//            print("No album")
//        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

    }
    
    
    // MARK: - Action Methods

    @IBAction func alternativeAlbumsButtonTapped(_ sender: UIButton) {
        
        albumGroup = albumResults[sender.tag]
        pagerView.reloadData()
        
        alternativeAlbumsViewHeightConstraint.constant = alternativeAlbumsViewHeightConstraint.constant == albumsViewHeight ? 0 : albumsViewHeight
        UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseInOut, animations: {
            self.view.layoutIfNeeded()
        }) { _ in
            self.originalPoint = self.alternativeAlbumsView.center
        }
    }
    
    
    // MARK: - Private Methods
    
    @objc func dismissAlternativeAlbumsView(_ gesture: UIPanGestureRecognizer) {
        
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
                
            } else {
                
                UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseInOut, animations: {
                    albumsView.center = CGPoint(x: albumsView.center.x, y: self.originalPoint.y)
                })
            }
            
        default:
            break
        }
    }

    


    
    // MARK: - UICollectionViewDataSource + Delegate


    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return albumResults.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "albumCell", for: indexPath) as! AlbumCVCell
        cell.imageView.backgroundColor = .white
        let albumGroup = albumResults[indexPath.item]
        
        if !albumGroup.isEmpty {
            let firstAlbum = albumGroup[0]
            let albumCoverString = firstAlbum.images[0].url
            
            print("ALBUM NAME: \(firstAlbum.name)")
            print("AMOUNT OF OPTIONS: \(albumGroup.count)")
            
            if albumGroup.count == 1 {
                cell.alternativesButtonView.isHidden = true
            }
            
            cell.albumTitleTextLabel.text = firstAlbum.name
            cell.artistTextLabel.text = firstAlbum.artists[0].name
            cell.alternativesButton.tag = indexPath.item
            
            // Download and cahce album cover image
            let imageURL = URL(string: albumCoverString)
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
                case .success(let value):
                    print("Task done for: \(value.source.url?.absoluteString ?? "")")
                case .failure(let error):
                    print("Job failed: \(error.localizedDescription)")
                }
            }
        }
        

//        cell.layer.cornerRadius = 10
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

    }

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    
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

extension SpotifyAlbumResultsCVC: FSPagerViewDelegate, FSPagerViewDataSource {
    
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        return albumGroup.count
    }
    
    
    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "cell", at: index) as! PagerViewCell
        let album = albumGroup[index]
        let albumCoverString = album.images[0].url
//        print(albumGroup.count)
//        print(index)
//        print(album.name)
        

        
        cell.albumTitleLabel?.text = album.name
        
        // Download and cache album cover image
        let imageURL = URL(string: albumCoverString)
        cell.imageView?.kf.setImage(with: imageURL)
        cell.imageView?.contentMode = .scaleAspectFit
//        cell.imageView?.layer.borderColor = UIColor.gray.cgColor
//        cell.imageView?.layer.borderWidth = 0.5
        cell.imageView?.layer.cornerRadius = 3
        
//        let processor = DownsamplingImageProcessor(size: (cell.imageView?.bounds.size)!)
//        |> RoundCornerImageProcessor(cornerRadius: 3)
//
//        cell.imageView?.kf.indicatorType = .activity
//        cell.imageView?.kf.setImage(
//            with: imageURL,
//            placeholder: UIImage(named: "placeholderImage"),
//            options: [
//                .processor(processor),
//                .scaleFactor(UIScreen.main.scale),
//                .transition(.fade(1)),
//                .cacheOriginalImage
//            ])
//        {
//            result in
//            switch result {
//            case .success(let value):
//                print("Task done for: \(value.source.url?.absoluteString ?? "")")
//            case .failure(let error):
//                print("Job failed: \(error.localizedDescription)")
//            }
//        }

        return cell
    }
    
    func pagerView(_ pagerView: FSPagerView, shouldHighlightItemAt index: Int) -> Bool {
        return false
    }
    
    
}
