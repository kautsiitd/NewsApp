//
//  CustomAlert.swift
//  NewsApp
//
//  Created by Kautsya Kanu on 06/01/20.
//  Copyright © 2020 Kautsya Kanu. All rights reserved.
//

import UIKit

enum CustomAlertAction {
    case retry(_ handler: ()?)
    case ok
    
    func title() -> String {
        switch self {
        case .retry(_): return "Retry"
        case .ok: return "Ok"
        }
    }
    
    func style() -> UIAlertAction.Style {
        switch self {
        case .retry(_): return .default
        case .ok: return .cancel
        }
    }
    
    func handler() -> ((UIAlertAction) -> Void)? {
        switch self {
        case .retry(let action): return {_ in action}
        case .ok: return nil
        }
    }
}

class CustomAlert: UIAlertController {
    convenience init(with error: CustomError, actions: [CustomAlertAction]) {
        self.init(title: error.title, message: error.description,
                  preferredStyle: .alert)
        for action in actions {
            let alertAction = UIAlertAction(title: action.title(),
                                            style: action.style(),
                                            handler: action.handler())
            addAction(alertAction)
        }
    }
}
