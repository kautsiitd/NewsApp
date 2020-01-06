//
//  BaseClass.swift
//  NewsApp
//
//  Created by Kautsya Kanu on 01/12/19.
//  Copyright © 2019 Kautsya Kanu. All rights reserved.
//

import Foundation

protocol ApiProtocol {
    func didFetchSuccessfully()
    func didFail(with error: CustomError)
}

protocol BaseClassProtocol: ApiProtocol {
    func apiEndPoint() -> String
    func parse(_ response: [String: Any])
}

class BaseClass: BaseClassProtocol {
    func apiEndPoint() -> String { return "" }
    func parse(_ response: [String : Any]) {}
    func didFetchSuccessfully() {}
    func didFail(with error: CustomError) {}
}
