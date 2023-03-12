//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Eugene Kolesnikov on 11.03.2023.
//

import Foundation
import UIKit

class AlertPresenter {
    let delegate: AlertPresenterDelegate?
    
    init(delegate: AlertPresenterDelegate) {
        self.delegate = delegate
    }
    
    func show(quiz result: AlertModel) {
        let alert = UIAlertController(title: result.title,
                                      message: result.message,
                                      preferredStyle: .alert)

        let action = UIAlertAction(title: result.buttonText, style: .default) { [weak self] _ in
            self?.delegate?.showQuizRezult()
        }

        alert.addAction(action)

        delegate?.present(alert, animated: true, completion: result.completion)
        
    }
}
