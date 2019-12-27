//
//  ArticleCore.swift
//  NewsApp
//
//  Created by Kautsya Kanu on 27/12/19.
//  Copyright © 2019 Kautsya Kanu. All rights reserved.
//

import Foundation
import CoreData

class ArticleCore: NSManagedObject {
    //MARK: Properties
    @NSManaged var title: String
    @NSManaged var newsLink: URL?
    @NSManaged var imageLink: URL?
    @NSManaged var image: NSData?
    @NSManaged var author: String
    @NSManaged var date: Date?
    @NSManaged var content: String
    
    @nonobjc class func fetchAll() -> NSFetchRequest<ArticleCore> {
        let request = NSFetchRequest<ArticleCore>(entityName: "\(ArticleCore.self)")
        let dateTimeSort = NSSortDescriptor(key: #keyPath(ArticleCore.date), ascending: false)
        request.sortDescriptors = [dateTimeSort]
        return request
    }
    
    func setData(article: Article) {
        title = article.title
        newsLink = article.newsLink
        imageLink = article.imageLink
        author = article.author
        date = article.publishedAt
        content = article.description
    }
}
