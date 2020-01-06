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
    private let baseURL = URL(string: "https://newsapi.org")!
    private let apiKey = "540b9c1f92984559801a044ae60a4bb6"
    
    func getRequest(for params: [String: Any] = [:],
                    _ delegate: BaseClassProtocol) {
        let endPoint = delegate.apiEndPoint()
        let newParams = getParams(from: params)
        guard let url = URL(string: endPoint, params: newParams, relativeTo: baseURL) else {
            delegate.didFail(with: .invalidURL)
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data,
                let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments),
                let response = json as? [String: Any] else {
                delegate.didFail(with: .invalidData)
                return
            }
            
            delegate.parse(response)
            delegate.didFetchSuccessfully()
        }
        task.resume()
    }
    
    private func getParams(from params: [String: Any]) -> [String: Any] {
        var newParams = params
        newParams["apiKey"] = apiKey
        return newParams
    }
}
