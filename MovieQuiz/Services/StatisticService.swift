//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Eugene Kolesnikov on 12.03.2023.
//

import Foundation

protocol StatisticService: AnyObject {
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
            userDefaults.integer(forKey: Keys.correct.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.correct.rawValue)
        }
    }
    var totalQuestions: Int {
        get {
            userDefaults.integer(forKey: Keys.total.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.total.rawValue)
        }
    }
    var gamesPlayed: Int {
        get {
            userDefaults.integer(forKey: Keys.gamesCount.rawValue)
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
        totalCorrectAnswers += result.correct
        totalQuestions += result.total
        gamesPlayed += 1
        if currentResultIsHigherThanRecord(current: result) {
            gameRecord = result
        }
    }
    
    private func currentResultIsHigherThanRecord(current result: GameRecord) -> Bool {
        return gameRecord < result
    }
    
    private enum Keys: String {
        case correct, total, gameRecord, gamesCount
    }
}
