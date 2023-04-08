//
//  ArrayTests.swift
//  MovieQuizTests
//
//  Created by Eugene Kolesnikov on 06.04.2023.
//

import Foundation
import XCTest
@testable import MovieQuiz

class ArrayTests: XCTestCase {
    func testGetValueInRange() throws {
        // Given
        let arr = [1, 1, 2, 3, 5]
        // When
        let value = arr[safe: 2]
        // Then
        XCTAssertNotNil(value)
        XCTAssertEqual(value, 2)
    }
    
    func testGetValueOutOfRange() throws {
        // Given
        let arr = [1, 2, 5, 6, 7]
        // When
        let value = arr[safe: 20]
        // Then
        XCTAssertNil(value)
    }
}
