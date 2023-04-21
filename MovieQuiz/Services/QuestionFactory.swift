//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Eugene Kolesnikov on 10.03.2023.
//

import Foundation

class QuestionFactory: QuestionFactoryProtocol {
    private let moviesLoader: MoviesLoading
    private weak var delegate: QuestionFactoryDelegate?
    private var movies: [MostPopularMovie] = []
    private var questionWord: QuestionWord?
    private var correctAnswer = false
    
    init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate) {
        self.moviesLoader = moviesLoader
        self.delegate = delegate
    }
    
    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let mostPopularMovies):
                    self.movies = mostPopularMovies.items
                    self.delegate?.didLoadDataFromServer()
                case .failure(let error):
                    self.delegate?.didFailToLoadData(with: error)
                }
            }
        }
    }
    
    func requestQuestion() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            let index = (0..<self.movies.count).randomElement() ?? 0
            
            guard let movie = self.movies[safe: index] else { return }
            
            var imageData = Data()
            
            do {
                imageData = try Data(contentsOf: movie.resizedImageURL)
            } catch {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.delegate?.didFailToLoadData(with: error)
                }
            }

            let question = self.ganerateQuestion(for: movie, with: imageData)
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.didReceiveNextQuestion(question: question)
            }
        }
    }
    
    private func ganerateQuestion(for movieLoaded: MostPopularMovie, with image: Data) -> QuizQuestion {
        let rating = Float(movieLoaded.rating) ?? 0
        let randomRatingToShow = generateRandomRatingToShow()
        
        if randomRatingToShow != rating {
            questionWord = QuestionWord.allCases.randomElement()
            switch questionWord {
            case .lesser:
                correctAnswer = randomRatingToShow > rating
            case .greater:
                correctAnswer = randomRatingToShow < rating
            case .equal:
                correctAnswer = randomRatingToShow == rating
            case .none:
                print("unable")
            }
        } else {
            questionWord = QuestionWord.equal
            correctAnswer = randomRatingToShow == rating
        }

        let questionWordToShow = questionWord?.rawValue ?? ""
        
        print("rating: \(rating)\nRatingToShow: \(randomRatingToShow)\nCorrect: \(correctAnswer)")

        let questionText = "Рейтинг этого фильма \(questionWordToShow) \(randomRatingToShow)?"
        
        let question = QuizQuestion(image: image,
                                    text: questionText,
                                    correctAnswer: correctAnswer)

        return question
    }
    
    private func generateRandomRatingToShow() -> Float {
        let randomRating = Float.random(in: 7.5...9.5)
        let randomRatingToString = String(format: "%.1f", randomRating)
        let randomRatingToFloat = Float(randomRatingToString) ?? 0
        return randomRatingToFloat
    }
    
    private enum QuestionWord: String, CaseIterable {
        case lesser = "меньше чем"
        case greater = "больше чем"
        case equal = "равeн"
    }
}
