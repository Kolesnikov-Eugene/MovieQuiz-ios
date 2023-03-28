//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Eugene Kolesnikov on 11.03.2023.
//

import UIKit

class AlertPresenter {
    weak var vc: UIViewController?
    
    init(vc: UIViewController) {
        self.vc = vc
    }
    
    func show(alert message: AlertModel) {
        let alert = UIAlertController(title: message.title,
                                      message: message.message,
                                      preferredStyle: .alert)
        
        let action = UIAlertAction(title: message.buttonText, style: .default) { _ in
            message.completion()
        }
        
        alert.addAction(action)
        
        vc?.present(alert, animated: true, completion: nil)
    }
}
