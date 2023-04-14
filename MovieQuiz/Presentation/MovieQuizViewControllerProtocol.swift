//
//  MovieQuizViewControllerProtocol.swift
//  MovieQuiz
//
//  Created by Eugene Kolesnikov on 14.04.2023.
//

import Foundation

protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func showGameResult(for gameResult: QuizResultsViewModel)
    
    func highlightImageBorder(isCorrectAnswer: Bool)
    func hideImageBorder()
    
    func showLoadingIndicator()
    func hideLoadingIndicator()
    
    func showNetworkError(message: String)
}
