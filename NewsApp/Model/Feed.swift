//
//  Feed.swift
//  NewsApp
//
//  Created by Kautsya Kanu on 02/12/19.
//  Copyright © 2019 Kautsya Kanu. All rights reserved.
//

import Foundation
import UIKit
import CoreData

enum FetchType {
    case saved
    case current
    case next
    case refresh
}

protocol FeedProtocol {
    func requestCompletedSuccessfully()
    func requestFailedWith(error: NSError?)
}

class Feed: BaseClass {
    //MARK: Properties
    private let context = CoreDataStack.shared.persistentContainer.viewContext
    
    private var status: String = "Fail"
    private var totalResults: Int = 0
    var articles: [ArticleData] = []
    private var delegate: FeedProtocol
    var currentPage: Int = 0
    var hasReachedEnd: Bool = false
    
    init(delegate: FeedProtocol) {
        self.delegate = delegate
    }
    
    //MARK: Available Functions
    func fetch(type: FetchType) {
        switch type {
        case .saved:
            do {
                articles = try context.fetch(ArticleData.fetchRequest())
            } catch let error as NSError {
              print("Could not fetch. \(error), \(error.userInfo)")
            }
            if articles.isEmpty {
                currentPage = 1
                let params: [String: Any] = ["country": "us",
                                             "page": currentPage]
                ApiManager.shared.getRequestWith(params: params,
                                                 delegate: self)
            } else {
                hasReachedEnd = true
                delegate.requestCompletedSuccessfully()
            }
            return
        case .next:
            currentPage += 1
        case .current:
            break
        case .refresh:
            deleteOld()
            currentPage = 1
        }
        let params: [String: Any] = ["country": "us",
                                     "page": currentPage]
        ApiManager.shared.getRequestWith(params: params,
                                         delegate: self)
    }
    
    private func deleteOld() {
        if let result = try? context.fetch(ArticleData.fetchRequest()) {
            for object in result {
                guard let object = object as? NSManagedObject else {
                    continue
                }
                context.delete(object)
            }
        }
        do {
            try context.save()
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    //MARK: ApiManagement
    override func getApiEndPoint() -> String {
        return "top-headlines"
    }
    
    override func parse(response: [String : Any]) {
        status = response["status"] as? String ?? "Fail"
        totalResults = response["totalResults"] as? Int ?? 0
        for responseElement in response["articles"] as? [[String: Any?]] ?? [] {
            let article = Article(response: responseElement)
            let articleData = ArticleData(entity: ArticleData.entity(),
                                          insertInto: context)
            articleData.title = article.title
            articleData.author = article.author
            articleData.content = article.content
            articleData.date = article.publishedAt
            articleData.newsDescription = article.description
            articleData.url = article.url?.absoluteString ?? ""
            articleData.urlToImage = article.urlToImage?.absoluteString ?? ""
            CoreDataStack.shared.saveContext()
            articles.append(articleData)
        }
        hasReachedEnd = (response["articles"] as? [Any])?.isEmpty ?? true
    }
    
    override func requestCompletedSuccessfully() {
        delegate.requestCompletedSuccessfully()
    }
    
    override func requestFailedWith(error: NSError?) {
        delegate.requestFailedWith(error: error)
    }
}
