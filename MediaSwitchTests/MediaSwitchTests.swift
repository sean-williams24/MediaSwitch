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

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    var albumResultsVC: AlbumResultsVC!

    override func setUp() {
        super.setUp()
        //1
//        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
//        let navigationController = storyboard.instantiateInitialViewController() as! UINavigationController
//        print(navigationController.viewControllers.count)
//        albumResultsVC = navigationController.viewControllers[1] as! AlbumResultsVC
//
//        //2
//        UIApplication.shared.keyWindow!.rootViewController = albumResultsVC
//
//        //3
//        XCTAssertNotNil(navigationController.view)
//        XCTAssertNotNil(albumResultsVC.view)
    }
    
    
    func testAppleButtonColours() {
        let connectVC = ConnectVC()
        let colours = connectVC.createColorSets()
        XCTAssertEqual(colours.count, 3, "apple button colours not loaded")
    }
    
    func testCloudTextRecognizerIsSelected() {
        let elementProcessor = ScaledElementProcessor()
        XCTAssertEqual(elementProcessor.textRecognizer, elementProcessor.vision.cloudTextRecognizer(), "cloud text recognizer not activated")
    }
    
//    func testDeleteAlbums() {
//         
//        let albumResultsVC = AlbumResultsVC()
////        albumResultsVC.collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
//        albumResultsVC.selectedAlbums = [IndexPath(item: 0, section: 0)]
//        albumResultsVC.viewingAppleMusic = true
////        albumResultsVC.appleAlbumResults = [[album]]
//        
//        XCTAssertEqual(albumResultsVC.appleAlbumResults.count, 1, "Results do not = 1")
////        albumResultsVC.deleteButtonTapped(UIButton())
//        XCTAssertEqual(albumResultsVC.appleAlbumResults.count, 0, "Results should be empty")
//
//        
//    }

}
