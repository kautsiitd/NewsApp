//
//  BaseClass.swift
//  NewsApp
//
//  Created by Kautsya Kanu on 01/12/19.
//  Copyright © 2019 Kautsya Kanu. All rights reserved.
//

import Foundation

protocol ApiProtocol {
    func didFetchSuccessfully(for params: [String: Any])
    func didFail(with error: CustomError)
}

protocol BaseClassProtocol: ApiProtocol {
    func apiEndPoint() -> String
    func parse(_ response: [String: Any], for params: [String: Any])
}

class BaseClass: BaseClassProtocol {
    func apiEndPoint() -> String { return "" }
    func parse(_ response: [String : Any], for params: [String: Any]) {}
    func didFetchSuccessfully(for params: [String: Any]) {}
    func didFail(with error: CustomError) {}
}
