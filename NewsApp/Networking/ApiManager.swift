//
//  ApiManager.swift
//  NewsApp
//
//  Created by Kautsya Kanu on 01/12/19.
//  Copyright © 2019 Kautsya Kanu. All rights reserved.
//

import Foundation
import UIKit

class ApiManager {
    
    //MARK: Properties
    static let shared = ApiManager()
    private init() {}
    private let baseURL = "https://newsapi.org/v2/"
    private let apiKey = "540b9c1f92984559801a044ae60a4bb6"
    
    func getRequestWith(params: [String: Any]?, delegate: BaseClassProtocol) {
        guard let url = URL(string: getURLWith(params: params, endPoint: delegate.getApiEndPoint())) else {
            delegate.requestFailedWith(error: .invalidURL)
            return
        }
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                delegate.requestFailedWith(error: .custom(error: error as NSError?))
                return
            }
            var json: Any
            do {
                json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            } catch {
                delegate.requestFailedWith(error: .invalidData)
                return
            }
            
            guard let responseDict = json as? [String: Any] else {
                delegate.requestFailedWith(error: .invalidData)
                return
            }
            
            delegate.parse(response: responseDict)
            delegate.requestCompletedSuccessfully()
        }
        task.resume()
    }
}

extension ApiManager {
    func getURLWith(params: [String: Any]?, endPoint: String) -> String {
        guard let params = params else {
            return baseURL
        }
        var paramsArray: [String] = ["apiKey=\(apiKey)"]
        for (key, value) in params {
            let value = "\(value)"
            paramsArray.append(key+"="+value)
        }
        var url = baseURL
        url += endPoint + "?" + paramsArray.joined(separator: "&")
        return url
    }
}
