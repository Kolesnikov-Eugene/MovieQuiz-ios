//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Eugene Kolesnikov on 09.04.2023.
//

import UIKit

final class MovieQuizPresenter {
    private weak var vc: MovieQuizViewController?
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var statisticService: StatisticService!
    private var currentQuestionIndex: Int = 0
    private var correctAnswersCounter = 0
    private let questionAmount: Int = 10
    
    init(vc: MovieQuizViewController) {
        self.vc = vc
        
        statisticService = StatisticServiceImplementation()
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        vc.showLoadingIndicator()
    }
    
    func noButtonPressed() {
        didAnswer(isYes: false)
    }
    
    func yesButtonPressed() {
        didAnswer(isYes: true)
    }
    
    private func isLastQuestion() -> Bool {
        return currentQuestionIndex == questionAmount - 1
    }
    
    func resetartGame() {
        currentQuestionIndex = 0
        correctAnswersCounter = 0
        questionFactory?.requestQuestion()
    }
    
    private func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    private func increaseCorrectAnswersCounter() {
        correctAnswersCounter += 1
    }
    
    private func didAnswer(isYes: Bool) {
        let userAnswer = isYes
        guard let currentQuestion = currentQuestion else { return }
        proceedWithAnswerResult(isCorrect: userAnswer == currentQuestion.correctAnswer)
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionAmount)")
    }
    
    private func proceedToNextQuestionOrResult() {
        if isLastQuestion() {
            let result = GameRecord(correct: correctAnswersCounter,
                                    total: questionAmount,
                                    date: Date())
            statisticService?.store(current: result)
            guard let statisticService else { return }
            let record = statisticService.gameRecord
            let quizResult = AlertModel(title: "Этот раунд окончен!",
                                        message: """
                                        Ваш результат: \(correctAnswersCounter) из \(questionAmount)
                                        Количество сыгранных квизов: \(statisticService.gamesPlayed)
                                        Рекорд:\
                                        \(record.correct)/\(record.total) (\(record.date.dateTimeString))
                                        Cредняя точность: \(statisticService.totalAccuracy)%
                                        """,
                                        buttonText: "Сыграть еще раз!") {
                DispatchQueue.main.async {
                    self.resetartGame()
                }
            }
            vc?.showGameResult(game: quizResult)
        } else {
            switchToNextQuestion()
            questionFactory?.requestQuestion()
        }
    }
    
    private func proceedWithAnswerResult(isCorrect: Bool) {
        if isCorrect {
            increaseCorrectAnswersCounter()
        }
        
        vc?.highlightImageBorder(isCorrectAnswer: isCorrect)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            guard let self = self else { return }
            self.vc?.hideImageBorder()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self = self else { return }
            self.proceedToNextQuestionOrResult()
        }
    }
}

// MARK: - QuestionFactoryDelegate
extension MovieQuizPresenter: QuestionFactoryDelegate {
    func didLoadDataFromServer() {
        vc?.activityIndicator.isHidden = true
        questionFactory?.requestQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        vc?.showNetworkError(message: error.localizedDescription)
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else { return }
        currentQuestion = question
        let convertedData = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.vc?.show(quiz: convertedData)
        }
    }
}

