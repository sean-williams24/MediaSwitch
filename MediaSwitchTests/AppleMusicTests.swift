//
//  AppleMusicTests.swift
//  MediaSwitchTests
//
//  Created by Sean Williams on 22/05/2020.
//  Copyright © 2020 Sean Williams. All rights reserved.
//

import XCTest
@testable import MediaSwitch

class AppleMusicTests: XCTestCase {
    
    var album: AppleMusicAlbum!
    
    override func setUp() {
        super.setUp()
        
        let artwork = Artwork(url: "apple.com/image1")
        let attributes = Attributes(artistName: "Slipknot", artwork: artwork, name: "Iowa")
        
        album = AppleMusicAlbum(attributes: attributes, href: "url", id: "1000qkkjww", type: "album")
    }
    
    func testAppleAlbumName() {
        XCTAssertEqual(album.attributes.artistName, "Slipknot", "Invalid artist name")
    }
    
    func testAlbumType() {
        XCTAssertEqual(album.type, "album", "album type is not album")
    }
    
    func testArtwork() {
        XCTAssertEqual(album.attributes.artwork.url, "apple.com/image1", "invalid artwork url")
    }
    
    
}
