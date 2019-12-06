//
//  Article.swift
//  NewsApp
//
//  Created by Kautsya Kanu on 02/12/19.
//  Copyright © 2019 Kautsya Kanu. All rights reserved.
//

import Foundation
import CoreData

class Source {
    //MARK: Properties
    private var id: Int
    var name: String
    
    init(response: [String: Any?]) {
        id = response["id"] as? Int ?? 0
        name = response["name"] as? String ?? ""
    }
}

class Article: NSManagedObject {
    //MARK: Properties
    @NSManaged var author: String
    @NSManaged var title: String
    @NSManaged var newsDescription: String
    @NSManaged var url: URL?
    @NSManaged var urlToImage: URL?
    @NSManaged var publishedAt: String
    @NSManaged var content: String
    
    @nonobjc class func fetchRequest() -> NSFetchRequest<Article> {
        return NSFetchRequest<Article>(entityName: "Article")
    }
    
    func setData(articleRemote: ArticleRemote) {
        author = articleRemote.author
        title = articleRemote.title
        newsDescription = articleRemote.description
        url = articleRemote.url
        urlToImage = articleRemote.urlToImage
        publishedAt = articleRemote.publishedAt
        content = articleRemote.content
    }
}
