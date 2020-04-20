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
    
    static func storeURL(for appGroup: String, databaseName: String) -> URL {
        guard let fileContainer = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroup) else {
            fatalError("Shared file container could not be created.")
        }
        return fileContainer.appendingPathComponent("\(databaseName).sqlite")
    }
}
