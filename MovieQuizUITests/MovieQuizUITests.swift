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
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        
        app.terminate()
        app = nil
    }
    
    func testYesButton() {
        sleep(3)
        let firstPoster = app.images["Poster"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        app.buttons["Yes"].tap()
        sleep(1)
        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        
        XCTAssertNotEqual(firstPosterData, secondPosterData)
    }
    
    func testNoButton() {
        sleep(3)
        let firstPoster = app.images["Poster"]
        let firstPostetData = firstPoster.screenshot().pngRepresentation
        
        app.buttons["No"].tap()
        sleep(1)
        
        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        
        XCTAssertNotEqual(firstPostetData, secondPosterData)
    }
    
    func testAlertPresentation() {
        sleep(5)
        var taps = 0
        while taps < 10 {
            app.buttons["Yes"].tap()
            sleep(1)
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
            sleep(1)
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
