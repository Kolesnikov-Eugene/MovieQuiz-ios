//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Eugene Kolesnikov on 10.03.2023.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {               
    func didReceiveNextQuestion(question: QuizQuestion?)
}
