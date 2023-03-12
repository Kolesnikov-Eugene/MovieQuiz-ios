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
    var gamesPlayed: Int { get }
    var gameRecord: GameRecord { get }
}

final class StatisticServiceImplementation: StatisticService {
    private let userDefaults = UserDefaults.standard
    var totalAccuracy: Double {
        get {
            let totalQuestions: Double = Double(userDefaults.integer(forKey: Keys.total.rawValue))
            let totalCorrectAnswers: Double = Double(userDefaults.integer(forKey: Keys.correct.rawValue))
            let totalAccuracy: Double = totalCorrectAnswers / totalQuestions * 100
            let accuracyToString = String(format: "%.2f", totalAccuracy)
            if let accuracy = Double(accuracyToString) {
                return accuracy
            }
            return 0.0
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
        var totalCorrectAnswers = userDefaults.integer(forKey: Keys.correct.rawValue)
        var totalQuestions = userDefaults.integer(forKey: Keys.total.rawValue)
        gamesPlayed += 1
        totalCorrectAnswers += result.correct
        totalQuestions += result.total
        userDefaults.set(totalCorrectAnswers, forKey: Keys.correct.rawValue)
        userDefaults.set(totalQuestions, forKey: Keys.total.rawValue)
        if theRecordIsHighest(current: result) {
            let record = GameRecord(correct: result.correct, total: result.total, date: result.date)
            gameRecord = record
        }
    }
    
    private func theRecordIsHighest(current result: GameRecord) -> Bool {
        return gameRecord.correct < result.correct
    }
    
    private enum Keys: String {
        case correct, total, gameRecord, gamesCount
    }
}
