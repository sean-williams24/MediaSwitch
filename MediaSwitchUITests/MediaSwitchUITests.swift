//
//  MediaSwitchUITests.swift
//  MediaSwitchUITests
//
//  Created by Sean Williams on 24/05/2020.
//  Copyright © 2020 Sean Williams. All rights reserved.
//

import XCTest
@testable import MediaSwitch

class MediaSwitchUITests: XCTestCase {

    override func setUpWithError() throws {
        let app = XCUIApplication()
        app.launch()

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTOSSignpostMetric.applicationLaunch]) {
                XCUIApplication().launch()
            }
        }
    }
}
