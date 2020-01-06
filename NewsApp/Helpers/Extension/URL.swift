//
//  URL.swift
//  NewsApp
//
//  Created by Kautsya Kanu on 03/01/20.
//  Copyright © 2020 Kautsya Kanu. All rights reserved.
//

import Foundation

extension URL {
    public init?(string: String, params: [String: Any], relativeTo url: URL?) {
        let paramsString = params.map { key, value in
            return "\(key)=\(value)"
        }.joined(separator: "&")
        
        let urlString = string + "?" + paramsString
        self.init(string: urlString, relativeTo: url)
    }
    
    func safeURL() -> URL? {
        let isValid = self.absoluteString.starts(with: "https://")
        if isValid { return self }
        return nil
    }
}
