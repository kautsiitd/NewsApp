//
//  CustomError.swift
//  NewsApp
//
//  Created by Kautsya Kanu on 26/12/19.
//  Copyright © 2019 Kautsya Kanu. All rights reserved.
//

import Foundation

enum CustomError {
    case invalidURL
    case invalidData
    case custom(error: NSError?)

    var title: String {
        switch self {
        case .invalidURL:
            return "InvalidURL"
        case .invalidData:
            return "InvalidData"
        case let .custom(error):
            return error?.domain ?? "Oops!!"
        }
    }
    
    var description: String {
        switch self {
        case .invalidURL:
            return "Can't Open"
        case .invalidData:
            return "Can't Open"
        case let .custom(error):
            return error?.localizedDescription ?? "Something went wrong 😭"
        }
    }
}
