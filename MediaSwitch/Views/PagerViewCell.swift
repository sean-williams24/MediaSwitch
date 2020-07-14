//
//  PagerView.swift
//  CDSaver
//
//  Created by Sean Williams on 28/02/2020.
//  Copyright © 2020 Sean Williams. All rights reserved.
//

import Foundation
import UIKit
import FSPagerView

class PagerViewCell: FSPagerViewCell {
    
    var albumTitleLabel: UILabel?

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let font = UIFont(name: "HelveticaNeue-Light", size: 13)
        albumTitleLabel = UILabel(frame: CGRect(x: 0, y: self.bounds.height, width: self.bounds.width, height: 30))
        albumTitleLabel?.textColor = .white
        albumTitleLabel?.font = font
        albumTitleLabel?.textAlignment = .left
        albumTitleLabel?.lineBreakMode = .byWordWrapping
        albumTitleLabel?.numberOfLines = 2
        albumTitleLabel?.backgroundColor = .clear
        albumTitleLabel?.preferredMaxLayoutWidth = self.bounds.width
        self.addSubview(albumTitleLabel!)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
