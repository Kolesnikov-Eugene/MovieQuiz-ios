//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Eugene Kolesnikov on 09.04.2023.
//

import UIKit

final class MovieQuizPresenter {
    private var currentQuestionIndex: Int = 0
    var currentQuestion: QuizQuestion?
    weak var vc: MovieQuizViewController?
    let questionAmount: Int = 10
    
    func noButtonPressed() {
        let userAnswer = false
        guard let currentQuestion = currentQuestion else { return }
        vc?.showAnswerResult(isCorrect: userAnswer == currentQuestion.correctAnswer)
    }
    
    func yesButtonPressed() {
        let userAnswer = true
        guard let currentQuestion = currentQuestion else { return }
        vc?.showAnswerResult(isCorrect: userAnswer == currentQuestion.correctAnswer)
    }
    
    func isLastQuestion() -> Bool {
        return currentQuestionIndex == questionAmount - 1
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionAmount)")
    }
}
