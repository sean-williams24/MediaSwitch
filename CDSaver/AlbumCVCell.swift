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
    
    override var isSelected: Bool {
        didSet {
            imageView.layer.borderWidth = isSelected ? 1.5 : 0
            blurredEffectView.frame = imageView.bounds
            
            UIView.animate(withDuration: 0.4) {
                let blurEffect = UIBlurEffect(style: .systemChromeMaterialDark)
                self.blurredEffectView.effect = self.isSelected ? blurEffect : nil
            }

        }
    }
    var blurredEffectView = UIVisualEffectView()

    
  override func awakeFromNib() {
      super.awakeFromNib()
    
    imageView.layer.cornerRadius = 3
    alternativesButtonView.layer.borderWidth = 1
    alternativesButtonView.layer.cornerRadius = 3
    alternativesButtonView.layer.borderColor = UIColor.init(white: 0.7, alpha: 0.5).cgColor
    alternativesButtonView.backgroundColor = UIColor.init(white: 0.3, alpha: 0.5)
    alternativesButton.tintColor = .white
    
    imageView.layer.borderColor = UIColor.darkGray.cgColor
    isSelected = false
    
    blurredEffectView.effect = nil
    blurredEffectView.frame = imageView.bounds
    imageView.addSubview(blurredEffectView)
    blurredEffectView.alpha = 0.8
    
  }
}
