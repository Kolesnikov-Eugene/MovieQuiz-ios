//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Eugene Kolesnikov on 12.03.2023.
//

import Foundation

protocol StatisticService {
    func store(current result: GameRecord)
    var totalAccuracy: Double { get }
    var totalCorrectAnswers: Int { get }
    var totalQuestions: Int { get }
    var gamesPlayed: Int { get }
    var gameRecord: GameRecord { get }
}

final class StatisticServiceImplementation: StatisticService {
    
    private let userDefaults = UserDefaults.standard
    var totalAccuracy: Double {
        get {
            let totalAccuracy: Double = Double(totalCorrectAnswers) / Double(totalQuestions) * 100
            let accuracyToString = String(format: "%.2f", totalAccuracy)
            if let accuracy = Double(accuracyToString) {
                return accuracy
            }
            return 0.0
        }
    }
    
    var totalCorrectAnswers: Int {
        get {
            let totalCorrect = userDefaults.integer(forKey: Keys.correct.rawValue)
            return totalCorrect
        }
        set {
            userDefaults.set(newValue, forKey: Keys.correct.rawValue)
        }
    }
    
    var totalQuestions: Int {
        get {
            let totalQuestionsCount = userDefaults.integer(forKey: Keys.total.rawValue)
            return totalQuestionsCount
        }
        set {
            userDefaults.set(newValue, forKey: Keys.total.rawValue)
        }
    }
    
    var gamesPlayed: Int {
        get {
            let games = userDefaults.integer(forKey: Keys.gamesCount.rawValue)
            return games
        }
        set {
            userDefaults.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    var gameRecord: GameRecord {
        get {
            guard let data = userDefaults.data(forKey: Keys.gameRecord.rawValue),
                  let record = try? JSONDecoder().decode(GameRecord.self, from: data) else {
                return .init(correct: 0, total: 0, date: Date())
            }
            return record
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                return
            }
            userDefaults.set(data, forKey: Keys.gameRecord.rawValue)
        }
    }
    
    func store(current result: GameRecord) {
        totalCorrectAnswers += 1
        totalQuestions += 1
        gamesPlayed += 1
        if currentResultIsHigherThanRecord(current: result) {
            let record = GameRecord(correct: result.correct, total: result.total, date: result.date)
            gameRecord = record
        }
    }
    
    private func currentResultIsHigherThanRecord(current result: GameRecord) -> Bool {
        return gameRecord.correct < result.correct
    }
    
    private enum Keys: String {
        case correct, total, gameRecord, gamesCount
    }
}
