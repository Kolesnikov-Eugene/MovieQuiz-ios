import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate, AlertPresenterDelegate {
    // MARK: - Lifecycle
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var textLabel: UILabel!

    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    
    private var currentQuestionIndex: Int = 0
    private var correctAnswersCounter: Int = 0
    private let questionAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var alertPresenter: AlertPresenter?
    private let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        questionFactory = QuestionFactory(delegate: self)
        alertPresenter = AlertPresenter(delegate: self)
        imageView.layer.cornerRadius = 8
        questionFactory?.requestQuestion()
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {return}
        currentQuestion = question
        let convertedData = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: convertedData)
        }
    }
    
    func showQuizRezult() {
        currentQuestionIndex = 0
        correctAnswersCounter = 0
        questionFactory?.requestQuestion()
    }
    
    @IBAction private func noButtonPressed(_ sender: UIButton) {
        disableButtons()
        let userAnswer = false
        guard let currentQuestion = currentQuestion else {return}
        showAnswerResult(isCorrect: userAnswer == currentQuestion.correctAnswer)
    }
    
    @IBAction private func yesButtonPressed(_ sender: UIButton) {
        disableButtons()
        let userAnswer = true
        guard let currentQuestion = currentQuestion else {return}
        showAnswerResult(isCorrect: userAnswer == currentQuestion.correctAnswer)
    }
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        counterLabel.text = step.questionNumber
        textLabel.text = step.question
        enableButtons()
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(image: UIImage(named: model.image) ?? UIImage(),
                                 question: model.text,
                                 questionNumber: "\(currentQuestionIndex + 1)/\(questionAmount)")
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        makeImageRoundAndCreateBorder()
        
        if isCorrect {
            imageView.layer.borderColor = UIColor.ypGreen.cgColor
            correctAnswersCounter += 1
        } else {
            imageView.layer.borderColor = UIColor.ypRed.cgColor
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            guard let self = self else {return}
            self.imageView.layer.borderWidth = 0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self = self else {return}
            self.showNextQuestionOrResult()
        }
    }
    
    private func showNextQuestionOrResult() {
        if currentQuestionIndex == questionAmount - 1 {
            let record = checkIfTheRecordIsHighest(correctAnswers: correctAnswersCounter)
            let gamePlayed = increaseGamePlayedCounter()
            let dateOfRecord = defaults.string(forKey: "DateOfRecord") ?? "current"
            let quizResult = AlertModel(title: "Этот раунд окончен!", message: "Ваш результат: \(correctAnswersCounter) из \(questionAmount) \nРекорд: \(record) (\(dateOfRecord)) \nИгры: \(gamePlayed)", buttonText: "Сыграть еще раз!")
            alertPresenter?.show(quiz: quizResult)
        } else {
            currentQuestionIndex += 1
            questionFactory?.requestQuestion()
            enableButtons()
        }
    }
    
    private func makeImageRoundAndCreateBorder() {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 5
        imageView.layer.cornerRadius = 8
    }
    
    private func checkIfTheRecordIsHighest(correctAnswers: Int) -> Int {
        let userRecord = defaults.integer(forKey: "UserRecord")
        if correctAnswers > userRecord {
            defaults.set(correctAnswers, forKey: "UserRecord")
            setDateAndTimeOfRecord()
            return correctAnswers
        } else {
            return userRecord
        }
    }
    
    private func increaseGamePlayedCounter() -> Int {
        var gamePlayed = defaults.integer(forKey: "GamePlayed")
        gamePlayed += 1
        defaults.set(gamePlayed, forKey: "GamePlayed")
        return gamePlayed
    }
    
    private func setDateAndTimeOfRecord() {
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy HH:mm"
        let dateToString = dateFormatter.string(from: currentDate)
        defaults.set(dateToString, forKey: "DateOfRecord")
    }
    
    private func disableButtons() {
        noButton.isEnabled = false
        yesButton.isEnabled = false
    }
    
    private func enableButtons() {
        noButton.isEnabled = true
        yesButton.isEnabled = true
    }
}

//struct ViewModel {
//    let image: UIImage
//    let question: String
//    let questionNumber: String
//}


/*
 Mock-данные
 
 
 Картинка: The Godfather
 Настоящий рейтинг: 9,2
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: The Dark Knight
 Настоящий рейтинг: 9
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: Kill Bill
 Настоящий рейтинг: 8,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: The Avengers
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: Deadpool
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: The Green Knight
 Настоящий рейтинг: 6,6
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: Old
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ


 Картинка: The Ice Age Adventures of Buck Wild
 Настоящий рейтинг: 4,3
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ


 Картинка: Tesla
 Настоящий рейтинг: 5,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ


 Картинка: Vivarium
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 */
