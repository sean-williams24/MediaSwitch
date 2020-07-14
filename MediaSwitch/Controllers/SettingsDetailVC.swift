//
//  SettingsDetailVC.swift
//  MediaSwitch
//
//  Created by Sean Williams on 07/05/2020.
//  Copyright © 2020 Sean Williams. All rights reserved.
//

import UIKit

class SettingsDetailVC: UIViewController {
    
    @IBOutlet weak var textView: UITextView!
    
    var selectedSettingsOption = ""
    

    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        switch selectedSettingsOption {
        case "terms":
            textView.text = LegalContent.TermsAndConditions.rawValue
            
        case "privacy":
            textView.text = LegalContent.PrivacyPolicy.rawValue

        case "legal":
            textView.text = LegalContent.LegalInfo.rawValue
            
        case "contact":
            textView.text = LegalContent.Contact.rawValue

        default:
            textView.text = LegalContent.PrivacyPolicy.rawValue
        }
    }
}
