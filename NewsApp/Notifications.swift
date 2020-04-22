//
//  Notifications.swift
//  NewsApp
//
//  Created by Kautsya Kanu on 21/04/20.
//  Copyright © 2020 Kautsya Kanu. All rights reserved.
//

import Foundation

class Notifications {
    enum name {
        case languageChanged
        case countryChanged
        case updateBookmark(id: String, action: String)
    }
}
