//
//  SettingsTableVC.swift
//  MediaSwitch
//
//  Created by Sean Williams on 07/05/2020.
//  Copyright © 2020 Sean Williams. All rights reserved.
//

import UIKit

class SettingsTableVC: UITableViewController {
    
    var selectedOption = ""
    
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            selectedOption = "terms"
        case 1:
            selectedOption = "privacy"
        case 2:
            selectedOption = "legal"
        case 3:
            selectedOption = "contact"
        default:
            break
        }
        
        let vc = storyboard?.instantiateViewController(identifier: "SettingsDetailVC") as! SettingsDetailVC
        vc.selectedSettingsOption = selectedOption
        show(vc, sender: self)
    }
}



