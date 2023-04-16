//
//  MovieQuizPresenterTests.swift
//  MovieQuizTests
//
//  Created by Eugene Kolesnikov on 14.04.2023.
//

import XCTest
@testable import MovieQuiz

final class MovieQuizViewControllerMock: MovieQuizViewControllerProtocol {
    func show(quiz step: QuizStepViewModel) { }
    
    func highlightImageBorder(isCorrectAnswer: Bool) { }
    
    func hideImageBorder() { }
    
    func showLoadingIndicator() { }
    
    func hideLoadingIndicator() { }
    
    func showNetworkError(message: String) { }
    
    func showGameResult(for gameResult: MovieQuiz.QuizResultsViewModel) { }
}

final class MovieQuizPresenterTests: XCTestCase {
    func testPresenterConvertModel() throws {
        let viewControllerMock = MovieQuizViewControllerMock()
        let sut = MovieQuizPresenter(viewController: viewControllerMock)
        
        let emptyData = Data()
        let question = QuizQuestion(image: emptyData, text: "Question Text", correctAnswer: true)
        let viewModel = sut.convert(model: question)
        
        XCTAssertNotNil(viewModel.image)
        XCTAssertEqual(viewModel.question, "Question Text")
        XCTAssertEqual(viewModel.questionNumber, "1/10")
    }
}
