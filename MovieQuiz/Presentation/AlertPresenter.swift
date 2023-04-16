//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Eugene Kolesnikov on 11.03.2023.
//

import UIKit

class AlertPresenter {
    weak var viewController: UIViewController?
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func show(alert message: AlertModel) {
        let alert = UIAlertController(title: message.title,
                                      message: message.message,
                                      preferredStyle: .alert)
        alert.view.accessibilityIdentifier = "Quiz alert"
        let action = UIAlertAction(title: message.buttonText, style: .default) { _ in
            message.completion()
        }
        alert.addAction(action)
            
        viewController?.present(alert, animated: true, completion: nil)
    }
}
