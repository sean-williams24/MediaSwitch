//
//  ExtensionsTests.swift
//  MediaSwitchTests
//
//  Created by Sean Williams on 22/05/2020.
//  Copyright © 2020 Sean Williams. All rights reserved.
//

import XCTest
@testable import MediaSwitch

class ExtensionsTests: XCTestCase {
    
    var onlyNumbers: String!
    
    
    override func setUp() {
        super.setUp()
        
        onlyNumbers = "122345673"
    }
    
    // String
    // - isNumeric
    
    func testIsNumericStringExtensionWithLetters() {
        
        XCTAssert(onlyNumbers.isNumeric)
        
        onlyNumbers.append("hello")
        
        XCTAssertEqual(onlyNumbers.isNumeric, false)
        
    }
    
    func testIsNumericStringExtensionWithDashes() {
        
        XCTAssert(onlyNumbers.isNumeric)
        
        onlyNumbers.append("---")
        
        XCTAssert(onlyNumbers.isNumeric)
        
    }
    
    func testIsNumericStringExtensionWithDashesAndLetters() {
        
        XCTAssert(onlyNumbers.isNumeric)
        
        onlyNumbers.append("---hello")
        
        XCTAssertFalse(onlyNumbers.isNumeric)
        
    }
    
    
    // - withoutSpecialCharacters
    
    func testStringWithoutDollar() {
        let string = "$hello world"
        
        XCTAssertEqual(string.withoutSpecialCharacters, "hello world")
    }
    
    func testStringWithoutPlusSymbol() {
        var string = "+hello world"
        
        string = string.withoutSpecialCharacters
        
        XCTAssertEqual(string, "hello world")
    }
    
    func testStringWithoutEquals() {
        let string = "=hello world"
        
        XCTAssertEqual(string.withoutSpecialCharacters, "hello world")
    }
    
    func testStringWithoutPlusMinus() {
        let string = "±hello world"
        
        XCTAssertEqual(string.withoutSpecialCharacters, "hello world")
    }
    
    func testStringWithoutTilda() {
        let string = "~hello world"
        
        XCTAssertEqual(string.withoutSpecialCharacters, "hello world")
    }
    
    
    // Array
    // Removing duplicates
    
    func testRemovingDuplicateStrings() {
        
        var stringArray = ["hello", "world", "hello", "world"]
        
        XCTAssertEqual(stringArray.count, 4)
        
        stringArray.removeDuplicates()
        
        XCTAssertEqual(stringArray.count, 2)
    }
    
    func testRemoveDuplicateStrings() {
         
         var stringArray = ["hello", "world", "hello", "world"]
         
         XCTAssertEqual(stringArray.count, 4)
         
         stringArray.removeDuplicates()
         
         XCTAssertEqual(stringArray.count, 2)
     }
}
