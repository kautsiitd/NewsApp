//
//  ArticleRemote.swift
//  NewsApp
//
//  Created by Kautsya Kanu on 07/12/19.
//  Copyright © 2019 Kautsya Kanu. All rights reserved.
//

import Foundation

class ArticleRemote {
    //MARK: Properties
    var author: String
    var title: String
    var description: String
    var url: URL?
    var urlToImage: URL?
    var publishedAt: String
    var content: String
    
    init(response: [String: Any?]) {
        author = response["author"] as? String ?? ""
        title = response["title"] as? String ?? ""
        description = response["description"] as? String ?? ""

        let urlString = response["url"] as? String ?? ""
        url = URL(string: urlString)

        let urlToImageString = response["urlToImage"] as? String ?? ""
        urlToImage = URL(string: urlToImageString)

        publishedAt = response["publishedAt"] as? String ?? "TA"
        content = response["content"] as? String ?? ""
    }
}
