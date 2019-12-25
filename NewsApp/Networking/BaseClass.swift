//
//  BaseClass.swift
//  NewsApp
//
//  Created by Kautsya Kanu on 01/12/19.
//  Copyright © 2019 Kautsya Kanu. All rights reserved.
//

import Foundation

protocol BaseClassProtocol {
    func getApiEndPoint() -> String
    func parse(response: [String: Any])
    func requestCompletedSuccessfully()
    func requestFailedWith(error: CustomError)
}

class BaseClass: BaseClassProtocol {
    func getApiEndPoint() -> String {
        return ""
    }
    func parse(response: [String : Any]) {}
    func requestCompletedSuccessfully() {}
    func requestFailedWith(error: CustomError) {}
}
