//
//  ArticleRemote.swift
//  NewsApp
//
//  Created by Kautsya Kanu on 02/12/19.
//  Copyright © 2019 Kautsya Kanu. All rights reserved.
//

import Foundation
import CoreData

struct Source {
    //MARK: Properties
    private let id: Int
    let name: String
    
    init(response: [String: Any?]) {
        id = response["id"] as? Int ?? 0
        name = response["name"] as? String ?? ""
    }
    
    init(name: String) {
        id = 0
        self.name = name
    }
}

class ArticleRemote {
    //MARK: Properties
    var source: Source
    var author: String
    var title: String
    var description: String
    var newsLink: URL?
    var imageLink: URL?
    var publishedAt: Date?
    var content: String
    
    //MARK: Variables
    let formatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ssZ"
        return dateFormatter
    }()
    
    init(response: [String: Any?]) {
        let sourceDict = response["source"] as? [String: Any?] ?? [:]
        source = Source(response: sourceDict)
        
        author = response["author"] as? String ?? ""
        title = response["title"] as? String ?? ""
        description = response["description"] as? String ?? ""

        var urlString = response["url"] as? String ?? ""
        newsLink = URL(string: urlString)

        urlString = response["urlToImage"] as? String ?? ""
        imageLink = URL(string: urlString)
        
        var dateString = response["publishedAt"] as? String ?? ""
        dateString = dateString.replacingOccurrences(of: "T", with: " ")
        publishedAt = formatter.date(from: dateString)
        
        content = response["content"] as? String ?? ""
    }
    
    init(article: Article) {
        source = Source(name: article.source)
        author = article.author
        title = article.title
        description = article.content
        newsLink = article.newsLink
        imageLink = article.imageLink
        publishedAt = article.date
        content = ""
    }
}
