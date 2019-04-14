//
//  Project_39_Unit_testing_with_XCTestTests.swift
//  Project 39 Unit testing with XCTestTests
//
//  Created by Gerjan te Velde on 10/04/2019.
//  Copyright © 2019 Gerjan te Velde. All rights reserved.
//

import XCTest
@testable import Project_39_Unit_testing_with_XCTest

class Project_39_Unit_testing_with_XCTestTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testAllWordsLoaded() {
        let playData = PlayData()
        XCTAssertEqual(playData.allWords.count, 18440, "allWords was not 18440")
    }
    
    func testWordCountsAreCorrect() {
        let playData = PlayData()
        
        XCTAssertEqual(playData.wordCounts.count(for: "home"), 174, "Home does not appear 174 times")
        XCTAssertEqual(playData.wordCounts.count(for: "fun"), 4, "Fun does not appear 4 times")
        XCTAssertEqual(playData.wordCounts.count(for: "mortal"), 41, "Mortal does not appear 41 times")
    }
    
    func testUserFilterWorks() {
        let playData = PlayData()
        
        playData.applyUserFilter("1")
        XCTAssertEqual(playData.filteredWords.count, 18440, "There are not 18440 words that appear 1 or more times.")
        
        playData.applyUserFilter("100")
        XCTAssertEqual(playData.filteredWords.count, 495, "There are not 495 words that appear more than 100 times.")
        
        playData.applyUserFilter("1000")
        XCTAssertEqual(playData.filteredWords.count, 55, "There are not 55 words that appear more than 1000 times.")
        
        playData.applyUserFilter("10000")
        XCTAssertEqual(playData.filteredWords.count, 1, "There is not 1 word that appears more than 10000 times.")
        
        playData.applyUserFilter("test")
        XCTAssertEqual(playData.filteredWords.count, 56, "Test does not appear 56 times.")
        
        playData.applyUserFilter("swift")
        XCTAssertEqual(playData.filteredWords.count, 7, "Swift does not appear 7 times.")
        
        playData.applyUserFilter("objective-c")
        XCTAssertEqual(playData.filteredWords.count, 0, "Objective-c does not appear 0 times.")
    }
    
    func testWordsLoadQuickly() {
        measure {
            _ = PlayData()
        }
    }
    
    func testWordsFilterQuickly() {
        let playData = PlayData()
        
        measure {
            playData.applyUserFilter("test")
        }
    }
}
