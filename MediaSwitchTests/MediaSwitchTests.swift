//
//  MediaSwitchTests.swift
//  MediaSwitchTests
//
//  Created by Sean Williams on 21/05/2020.
//  Copyright © 2020 Sean Williams. All rights reserved.
//

import XCTest
@testable import MediaSwitch


class MediaSwitchTests: XCTestCase {
    
    func testAppleButtonColours() {
        let connectVC = ConnectVC()
        let colours = connectVC.createColorSets()
        XCTAssertEqual(colours.count, 3, "apple button colours not loaded")
    }
    
    func testCloudTextRecognizerIsSelected() {
        let elementProcessor = ScaledElementProcessor()
        XCTAssertEqual(elementProcessor.textRecognizer, elementProcessor.vision.cloudTextRecognizer(), "cloud text recognizer not activated")
    }
    


}
