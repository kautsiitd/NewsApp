//
//  Article.swift
//  NewsApp
//
//  Created by Kautsya Kanu on 02/12/19.
//  Copyright © 2019 Kautsya Kanu. All rights reserved.
//

import Foundation

class Source {
    //MARK: Properties
    private var id: Int
    var name: String
    
    init(response: [String: Any?]) {
        id = response["id"] as? Int ?? 0
        name = response["name"] as? String ?? ""
    }
}

class Article {
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
        
        publishedAt = response["publishedAt"] as? String ?? ""
        content = response["content"] as? String ?? ""
    }
}
