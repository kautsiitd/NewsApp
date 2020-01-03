//
//  URL.swift
//  NewsApp
//
//  Created by Kautsya Kanu on 03/01/20.
//  Copyright © 2020 Kautsya Kanu. All rights reserved.
//

import Foundation

extension URL {
    func safeURL() -> URL? {
        let isValid = self.absoluteString.starts(with: "https://")
        if isValid { return self }
        return nil
    }
}
