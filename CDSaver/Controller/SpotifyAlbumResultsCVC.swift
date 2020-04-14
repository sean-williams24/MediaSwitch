//
//  SpotifyAlbumResultsCVC.swift
//  CDSaver
//
//  Created by Sean Williams on 08/04/2020.
//  Copyright © 2020 Sean Williams. All rights reserved.
//

import FSPagerView
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
    private let sectionInsets = UIEdgeInsets(top: 15.0, left: 10.0, bottom: 15.0, right: 10.0)
    var itemsPerRow: CGFloat = 2
    let albumsViewHeight: CGFloat = 290
    
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.contentInsetAdjustmentBehavior = .never
        alternativeAlbumsView.backgroundColor = .clear
        
        alternativeAlbumsViewHeightConstraint.constant = albumsViewHeight
//        pagerView.transformer = FSPagerViewTransformer(type: .linear)
        let width = view.frame.width / 2
        pagerView.itemSize = CGSize(width: width, height: width)
        pagerView.isUserInteractionEnabled = true
        pagerView.backgroundColor = UIColor.black.withAlphaComponent(0.945)
        pagerView.interitemSpacing = 30
        
        
        
        
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

    @IBAction func alternativeAlbumsButtonTapped(_ sender: Any) {
        collectionView(collectionView, didSelectItemAt: IndexPath(item: 1, section: 1))
    }
    
    

    // MARK: - UICollectionViewDataSource + Delegate


    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 20
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "albumCell", for: indexPath) as! AlbumCVCell
//        let albumGroup = albumResults[indexPath.item]
//        
//        if !albumGroup.isEmpty {
//            let firstAlbum = albumGroup[0]
//
//            cell.albumTitleTextLabel.text = firstAlbum.name
//            cell.artistTextLabel.text = firstAlbum.artists[0].name
//        }
        
        cell.layer.cornerRadius = 10
//        cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        alternativeAlbumsViewHeightConstraint.constant = alternativeAlbumsViewHeightConstraint.constant == albumsViewHeight ? 0 : albumsViewHeight

        UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseInOut, animations: {
            self.view.layoutIfNeeded()
        }) { _ in
            
        }
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

    
    // MARK: UICollectionViewFlowDelegate

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: widthPerItem + 57)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        sectionInsets.left
    }

}

extension SpotifyAlbumResultsCVC: FSPagerViewDelegate, FSPagerViewDataSource {
    
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        return 10
    }
    
    
    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "cell", at: index) as! PagerViewCell
        let image = UIImage(named: "bakkos")
        cell.imageView?.image = image
        cell.imageView?.contentMode = .scaleAspectFit
        cell.imageView?.layer.borderColor = UIColor.gray.cgColor
        cell.imageView?.layer.borderWidth = 0.5
        
//        cell.imageView?.clipsToBounds = true
        
        cell.albumTitleLabel?.text = "The Killing"
        
        return cell
    }
    
    func pagerView(_ pagerView: FSPagerView, shouldHighlightItemAt index: Int) -> Bool {
        return false
    }
    
    
}
