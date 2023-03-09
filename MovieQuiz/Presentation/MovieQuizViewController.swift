import UIKit

final class MovieQuizViewController: UIViewController {
    // MARK: - Lifecycle
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var textLabel: UILabel!

    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    
    private var currentQuestionIndex: Int = 0
    private var correctAnswersCounter: Int = 0
    private let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        makeImageRoundAndCreateBorder()
        let firstQuestion = questions[currentQuestionIndex]
        let convertedData = convert(model: firstQuestion)
        show(quiz: convertedData)
        
    }
    
    @IBAction private func noButtonPressed(_ sender: UIButton) {
        disableButtons()
        let userAnswer = false
        let currentQuestion = questions[currentQuestionIndex]
        showAnswerResult(isCorrect: userAnswer == currentQuestion.correctAnswer)
    }
    
    @IBAction private func yesButtonPressed(_ sender: UIButton) {
        disableButtons()
        let userAnswer = true
        let currentQuestion = questions[currentQuestionIndex]
        showAnswerResult(isCorrect: userAnswer == currentQuestion.correctAnswer)
    }
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        counterLabel.text = step.questionNumber
        textLabel.text = step.question
        enableButtons()
    }
    
    private func show(quiz result: QuizResultsViewModel) {
        let alert = UIAlertController(title: result.title,
                                      message: result.text,
                                      preferredStyle: .alert)

        let action = UIAlertAction(title: result.buttonText, style: .default) { [weak self] _ in
            guard let self = self else {return}
            self.currentQuestionIndex = 0
            self.correctAnswersCounter = 0
            
            let currentQuestion = self.questions[self.currentQuestionIndex]
            let convertedData = self.convert(model: currentQuestion)
            
            self.show(quiz: convertedData)
        }

        alert.addAction(action)

        self.present(alert, animated: true, completion: nil)
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(image: UIImage(named: model.image) ?? UIImage(),
                                 question: model.text,
                                 questionNumber: "\(currentQuestionIndex + 1)/\(questions.count)")
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
        if currentQuestionIndex == questions.count - 1 {
            let record = checkIfTheRecordIsHighest(correctAnswers: correctAnswersCounter)
            let gamePlayed = increaseGamePlayedCounter()
            let dateOfRecord = defaults.string(forKey: "DateOfRecord") ?? "current"
            let quizResult = QuizResultsViewModel(title: "Этот раунд окончен!",
                                                  text: "Ваш результат: \(correctAnswersCounter) из \(questions.count) \nРекорд: \(record) (\(dateOfRecord)) \nИгры: \(gamePlayed)",
                                             buttonText: "Сыграть еще раз!")
            show(quiz: quizResult)
        } else {
            currentQuestionIndex += 1
            let currentQuestion = questions[currentQuestionIndex]
            let convertedData = convert(model: currentQuestion)
            
            show(quiz: convertedData)
            enableButtons()
        }
    }
    
    private func makeImageRoundAndCreateBorder() {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 1
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
