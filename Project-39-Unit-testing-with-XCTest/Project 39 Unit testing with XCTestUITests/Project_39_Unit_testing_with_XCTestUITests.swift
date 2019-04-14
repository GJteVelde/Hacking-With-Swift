//
//  Project_39_Unit_testing_with_XCTestUITests.swift
//  Project 39 Unit testing with XCTestUITests
//
//  Created by Gerjan te Velde on 10/04/2019.
//  Copyright © 2019 Gerjan te Velde. All rights reserved.
//

import XCTest

class Project_39_Unit_testing_with_XCTestUITests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testInitialStateIsCorrect() {
        let table = XCUIApplication().tables
        XCTAssertEqual(table.cells.count, 7, "There should be 7 rows initially")
    }
    
    func testUserFilteringByString() {
        let app = XCUIApplication()
        app.buttons["Search"].tap()
        
        let filterAlert = app.alerts
        let textField = filterAlert.textFields.element
        textField.typeText("test")
        
        filterAlert.buttons["Filter"].tap()
        
        XCTAssertEqual(app.tables.cells.count, 56, "There should be 56 words matching 'test'")
    }
    
    func testUserFilteringByInt() {
        let app = XCUIApplication()
        app.buttons["Search"].tap()
        
        let filterAlert = app.alerts
        let textField = filterAlert.textFields.element
        textField.typeText("1000")
        
        filterAlert.buttons["Filter"].tap()
        
        XCTAssertEqual(app.tables.cells.count, 55, "There should be 55 rows with words that appear 1000 or more times.")
    }
    
    func testUserFilteringByIntOf1() {
        let app = XCUIApplication()
        app.buttons["Search"].tap()
        
        let filterAlert = app.alerts
        let textField = filterAlert.textFields.element
        textField.typeText("objective-c")
        
        filterAlert.buttons["Filter"].tap()
        
        XCTAssertEqual(app.tables.cells.count, 0, "There should be 0 words matching 'objective-c'.")
    }
    
    func testUserFilteringByEmptyString() {
        let app = XCUIApplication()
        app.buttons["Search"].tap()
        
        let filterAlert = app.alerts
        let textField = filterAlert.textFields.element
        textField.typeText("")
        
        filterAlert.buttons["Filter"].tap()
        
        XCTAssertEqual(app.tables.cells.count, 7, "There should be 7 rows when an empty string is inserted.")
    }
    
    func testUserFilteringCancelTapped() {
        //In this case 'swift' will be the word it searches for (same as on initialization of PlayData)
        let app = XCUIApplication()
        app.buttons["Search"].tap()
        
        let filterAlert = app.alerts
        filterAlert.buttons["Cancel"].tap()
        
        XCTAssertEqual(app.tables.cells.count, 7, "There should be 7 rows when 'Cancel' is tapped.")
    }
}
