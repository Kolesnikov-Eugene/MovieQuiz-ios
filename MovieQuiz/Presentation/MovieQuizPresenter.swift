//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Eugene Kolesnikov on 09.04.2023.
//

import UIKit

final class MovieQuizPresenter {
    private weak var vc: MovieQuizViewControllerProtocol?
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var statisticService: StatisticService!
    private var currentQuestionIndex: Int = 0
    private var correctAnswersCounter = 0
    private let questionAmount: Int = 10
    
    init(vc: MovieQuizViewControllerProtocol) {
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
    
    func resetartGame() {
        currentQuestionIndex = 0
        correctAnswersCounter = 0
        questionFactory?.requestQuestion()
    }
    
    func reloadData() {
        questionFactory?.loadData()
    }
    
    private func isLastQuestion() -> Bool {
        return currentQuestionIndex == questionAmount - 1
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
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionAmount)")
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
    
    private func proceedToNextQuestionOrResult() {
        if isLastQuestion() {
            let result = GameRecord(correct: correctAnswersCounter,
                                    total: questionAmount,
                                    date: Date())
            statisticService.store(current: result)
            
            let quizResult = createQuizResult()
            vc?.showGameResult(for: quizResult)
        } else {
            switchToNextQuestion()
            questionFactory?.requestQuestion()
        }
    }
    
    private func createQuizResult() -> QuizResultsViewModel {
        let record = statisticService.gameRecord
        let quizResult = QuizResultsViewModel(title: "Этот раунд окончен!",
                                    text: """
                                    Ваш результат: \(correctAnswersCounter) из \(questionAmount)
                                    Количество сыгранных квизов: \(statisticService.gamesPlayed)
                                    Рекорд:\
                                    \(record.correct)/\(record.total) (\(record.date.dateTimeString))
                                    Cредняя точность: \(statisticService.totalAccuracy)%
                                    """,
                                    buttonText: "Сыграть еще раз!")
        return quizResult
    }
}

// MARK: - QuestionFactoryDelegate
extension MovieQuizPresenter: QuestionFactoryDelegate {
    func didLoadDataFromServer() {
        vc?.hideLoadingIndicator()
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

