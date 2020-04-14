//
//  AlbumCVCell.swift
//  CDSaver
//
//  Created by Sean Williams on 08/04/2020.
//  Copyright © 2020 Sean Williams. All rights reserved.
//

import UIKit

class AlbumCVCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var albumTitleTextLabel: UILabel!
    @IBOutlet weak var artistTextLabel: UILabel!
    @IBOutlet weak var alternativesButtonView: UIView!
    @IBOutlet weak var alternativesButton: UIButton!
    
  override func awakeFromNib() {
      super.awakeFromNib()
      
    alternativesButtonView.layer.borderWidth = 1
    alternativesButtonView.layer.borderColor = UIColor.init(white: 0.7, alpha: 0.5).cgColor
    alternativesButtonView.backgroundColor = UIColor.init(white: 0.3, alpha: 0.5)
    alternativesButton.tintColor = .white
  }
}
