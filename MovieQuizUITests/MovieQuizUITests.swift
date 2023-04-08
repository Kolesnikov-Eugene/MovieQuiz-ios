//
//  MovieQuizUITests.swift
//  MovieQuizUITests
//
//  Created by Eugene Kolesnikov on 08.04.2023.
//

import XCTest

final class MovieQuizUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        try super.setUpWithError()
        
        app = XCUIApplication()
        app.launch()
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        
        app.terminate()
        app = nil
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

//    func testExample() throws {
//        // UI tests must launch the application that they test.
//        let app = XCUIApplication()
//        app.launch()
//
//        // Use XCTAssert and related functions to verify your tests produce the correct results.
//    }
    
    func testYesButton() {
        sleep(3)
        let firstPoster = app.images["Poster"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        app.buttons["Yes"].tap()
        sleep(3)
        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        
        XCTAssertNotEqual(firstPosterData, secondPosterData)
    }
    
    func testNoButton() {
        sleep(3)
        let firstPoster = app.images["Poster"]
        let firstPostetData = firstPoster.screenshot().pngRepresentation
        
        app.buttons["No"].tap()
        sleep(3)
        
        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        
        XCTAssertNotEqual(firstPostetData, secondPosterData)
    }
    
    func testAlertPresentation() {
        sleep(5)
        var taps = 0
        while taps < 10 {
            app.buttons["Yes"].tap()
            sleep(3)
            taps += 1
        }
        sleep(3)
        let alert = app.alerts["Quiz alert"]
        XCTAssertTrue(alert.exists)
        XCTAssertEqual(alert.label, "Этот раунд окончен!")
        XCTAssertEqual(alert.buttons.firstMatch.label, "Сыграть еще раз!")
    }
    
    func testAlertDismiss() {
        sleep(5)
        var taps = 0
        while taps < 10 {
            app.buttons["Yes"].tap()
            sleep(3)
            taps += 1
        }
        sleep(3)
        let alert = app.alerts["Quiz alert"]
        alert.buttons["Сыграть еще раз!"].tap()
        sleep(3)
        let indexLabel = app.staticTexts["Index"]
        let text = indexLabel.label
        XCTAssertFalse(alert.exists)
        XCTAssertEqual(text, "1/10")
    }
}
