//
//  Date.swift
//  NewsApp
//
//  Created by Kautsya Kanu on 27/12/19.
//  Copyright © 2019 Kautsya Kanu. All rights reserved.
//

import Foundation

extension Date {
    func convertTo(string: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = string
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        return formatter.string(from: self)
    }
}
