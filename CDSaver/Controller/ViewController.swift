//
//  ViewController.swift
//  CDSaver
//
//  Created by Sean Williams on 21/04/2020.
//  Copyright © 2020 Sean Williams. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let imageView = UIImageView(image: UIImage(named: "bakkos"))
        imageView.frame = view.bounds
        imageView.contentMode = .scaleAspectFit
        view.addSubview(imageView)

        let blurEffect = UIBlurEffect(style: .systemThinMaterialDark)
        let blurredEffectView = UIVisualEffectView(effect: blurEffect)
        blurredEffectView.frame = imageView.bounds
        view.addSubview(blurredEffectView)
        
        let segmentedControl = UILabel()
        segmentedControl.text = "Sean IS SOUND"
        segmentedControl.sizeToFit()
        segmentedControl.center = view.center

        let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect)
        let vibrancyEffectView = UIVisualEffectView(effect: vibrancyEffect)
        vibrancyEffectView.frame = imageView.bounds

        vibrancyEffectView.contentView.addSubview(segmentedControl)
        blurredEffectView.contentView.addSubview(vibrancyEffectView)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
