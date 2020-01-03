//
//  Article.swift
//  NewsApp
//
//  Created by Kautsya Kanu on 27/12/19.
//  Copyright © 2019 Kautsya Kanu. All rights reserved.
//

import Foundation
import CoreData

class Article: NSManagedObject {
    //MARK: Properties
    @NSManaged var title: String
    @NSManaged var newsLink: URL?
    @NSManaged var imageLink: URL?
    @NSManaged var author: String
    @NSManaged var date: Date?
    @NSManaged var content: String
    
    @nonobjc class func fetchAll() -> NSFetchRequest<Article> {
        let request = NSFetchRequest<Article>(entityName: "\(Article.self)")
        let dateTimeSort = NSSortDescriptor(key: #keyPath(Article.date), ascending: false)
        request.sortDescriptors = [dateTimeSort]
        return request
    }
    
    @nonobjc class func deleteAll() -> NSBatchDeleteRequest {
        let fetchRequest = NSFetchRequest<Article>(entityName: "\(Article.self)")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest as! NSFetchRequest<NSFetchRequestResult>)
        return deleteRequest
    }
    
    func setData(articleRemote: ArticleRemote) {
        title = articleRemote.title
        newsLink = articleRemote.newsLink
        imageLink = articleRemote.imageLink
        author = articleRemote.author
        date = articleRemote.publishedAt
        content = articleRemote.description
    }
}
