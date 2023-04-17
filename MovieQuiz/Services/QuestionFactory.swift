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

            let question = self.questionGenerator(for: movie, image: imageData)
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.didReceiveNextQuestion(question: question)
            }
        }
    }
    
    private func questionGenerator(for movieLoaded: MostPopularMovie, image: Data) -> QuizQuestion {
        let rating = Float(movieLoaded.rating) ?? 0
        let ratingToShow = generateRatingToShow()
        
        if ratingToShow != rating {
            questionWord = QuestionWord.allCases.randomElement()
            switch questionWord {
            case .lesser:
                correctAnswer = ratingToShow > rating
            case .greater:
                correctAnswer = ratingToShow < rating
            case .equal:
                correctAnswer = ratingToShow == rating
            case .none:
                print("unable")
            }
        } else {
            questionWord = QuestionWord.equal
            correctAnswer = ratingToShow == rating
        }

        let comparisonText = questionWord?.rawValue ?? ""
        
        print("rating: \(rating)\nRatingToShow: \(ratingToShow)\nCorrect: \(correctAnswer)")

        let questionText = "Рейтинг этого фильма \(comparisonText) \(ratingToShow)?"
        
        let question = QuizQuestion(image: image,
                                    text: questionText,
                                    correctAnswer: correctAnswer)

        return question
    }
    
    private func generateRatingToShow() -> Float {
        let newRating = Float.random(in: 7.5...9.5)
        let ratingToString = String(format: "%.1f", newRating)
        let ratingToFloat = Float(ratingToString) ?? 0
        return ratingToFloat
    }
    
    private enum QuestionWord: String, CaseIterable {
        case lesser = "меньше чем"
        case greater = "больше чем"
        case equal = "равeн"
    }
}
