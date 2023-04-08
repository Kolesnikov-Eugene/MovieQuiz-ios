//
//  MovieQuizTests.swift
//  MovieQuizTests
//
//  Created by Eugene Kolesnikov on 06.04.2023.
//

import XCTest

struct ArithmeticOperations {
    func addition(num1: Int, num2: Int, handler: @escaping (Int) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            handler(num1 + num2)
        }
    }
    
    func substraction(num1: Int, num2: Int, handler: @escaping (Int) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            handler(num1 - num2)
        }
    }
    
    func multiplication(num1: Int, num2: Int, handler: @escaping (Int) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            handler(num1 * num2)
        }
    }
}

final class MovieQuizTests: XCTestCase {
    func testAddition() throws {
        // Given
        let arithmeticOperations = ArithmeticOperations()
        let num1 = 1
        let num2 = 2
        
        // When
        let expectation = expectation(description: "Addition function expectation")
        
        arithmeticOperations.addition(num1: num1, num2: num2) { result in
            XCTAssertEqual(result, 3)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 2)
    }
}
