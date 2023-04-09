import UIKit

final class MovieQuizViewController: UIViewController {
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!

    private var correctAnswersCounter: Int = 0
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var alertPresenter: AlertPresenter?
    private var statisticService: StatisticService?
    private var presenter = MovieQuizPresenter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 20
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        alertPresenter = AlertPresenter(vc: self)
        statisticService = StatisticServiceImplementation()
        presenter.vc = self
        showLoadingIndicator()
        questionFactory?.loadData()
    }
    
    @IBAction private func noButtonPressed(_ sender: UIButton) {
        disableButtons()
        presenter.currentQuestion = currentQuestion
        presenter.noButtonPressed()
    }
    
    @IBAction private func yesButtonPressed(_ sender: UIButton) {
        disableButtons()
        presenter.currentQuestion = currentQuestion
        presenter.yesButtonPressed()
    }
    
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.isHidden = true
    }

    func disableButtons() {
        noButton.isEnabled = false
        yesButton.isEnabled = false
    }
    
    func enableButtons() {
        noButton.isEnabled = true
        yesButton.isEnabled = true
    }
}

// MARK: - QuestionFactoryDelegate

extension MovieQuizViewController: QuestionFactoryDelegate {
    func didLoadDataFromServer() {
        activityIndicator.isHidden = true
        questionFactory?.requestQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else { return }
        currentQuestion = question
        let convertedData = presenter.convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: convertedData)
        }
    }
    
    private func showNetworkError(message: String) {
        let model = AlertModel(title: "Ошибка",
                               message: message,
                               buttonText: "Попробовать еще раз") { [weak self] in
            guard let self else { return }
            self.presenter.resetQuestionIndex()
            self.correctAnswersCounter = 0
            self.questionFactory?.loadData()
        }
        alertPresenter?.show(alert: model)
    }
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        counterLabel.text = step.questionNumber
        textLabel.text = step.question
        enableButtons()
    }
    
    func showAnswerResult(isCorrect: Bool) {
        imageView.layer.borderWidth = 8
        
        if isCorrect {
            imageView.layer.borderColor = UIColor.ypGreen.cgColor
            correctAnswersCounter += 1
        } else {
            imageView.layer.borderColor = UIColor.ypRed.cgColor
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            guard let self = self else { return }
            self.imageView.layer.borderWidth = 0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self = self else { return }
            self.showNextQuestionOrResult()
        }
    }
    
    private func showNextQuestionOrResult() {
        if presenter.isLastQuestion() {
            let result = GameRecord(correct: correctAnswersCounter,
                                    total: presenter.questionAmount,
                                    date: Date())
            statisticService?.store(current: result)
            guard let statisticService else { return }
            let record = statisticService.gameRecord
            let quizResult = AlertModel(title: "Этот раунд окончен!",
                                        message: """
                                        Ваш результат: \(correctAnswersCounter) из \(presenter.questionAmount)
                                        Количество сыгранных квизов: \(statisticService.gamesPlayed)
                                        Рекорд:\
                                        \(record.correct)/\(record.total) (\(record.date.dateTimeString))
                                        Cредняя точность: \(statisticService.totalAccuracy)%
                                        """,
                                        buttonText: "Сыграть еще раз!") {
                DispatchQueue.main.async { [weak self] in
                    self?.presenter.resetQuestionIndex()
                    self?.correctAnswersCounter = 0
                    self?.questionFactory?.requestQuestion()
                }
            }
            alertPresenter?.show(alert: quizResult)
        } else {
            presenter.switchToNextQuestion()
            questionFactory?.requestQuestion()
        }
    }
}
