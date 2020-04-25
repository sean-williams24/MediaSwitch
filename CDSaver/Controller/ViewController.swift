//
//  ViewController.swift
//  CDSaver
//
//  Created by Sean Williams on 21/04/2020.
//  Copyright © 2020 Sean Williams. All rights reserved.
//

import SwiftJWT
import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let teamId = Auth.Apple.teamId
        let keyId = Auth.Apple.keyId
        let keyFileUrl = Bundle.main.url(forResource: "", withExtension: "p8")!

        struct MyClaims: Claims {
            let iss: String
            let iat: Date?
            let exp: Date?
        }

        let myHeader = Header(kid: keyId)
        let myClaims = MyClaims(iss: teamId, iat: Date(), exp: Date() +  24 * 60 * 60)
        var myJWT = SwiftJWT.JWT(header: myHeader, claims: myClaims)

        let token = try! myJWT.sign(using: .es256(privateKey: try! String(contentsOf: keyFileUrl).data(using: .utf8)!))
    }
    



}
