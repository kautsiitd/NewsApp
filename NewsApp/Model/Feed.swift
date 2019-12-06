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
    let context = CoreDataStack.shared.persistentContainer.viewContext
    
    private var status: String = "Fail"
    private var totalResults: Int = 0
    var articles: [Article] = []
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
                articles = try context.fetch(Article.fetchRequest())
            } catch let error as NSError {
              print("Could not fetch. \(error), \(error.userInfo)")
            }
            if !articles.isEmpty {
                hasReachedEnd = true
                delegate.requestCompletedSuccessfully()
                return
            } else {
                currentPage = 1
            }
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
        if let result = try? context.fetch(Article.fetchRequest()) {
            for object in result {
                guard let object = object as? NSManagedObject else {
                    continue
                }
                context.delete(object)
            }
        }
        CoreDataStack.shared.save(context: context)
    }
    
    //MARK: ApiManagement
    override func getApiEndPoint() -> String {
        return "top-headlines"
    }
    
    override func parse(response: [String : Any]) {
        context.performAndWait {
            status = response["status"] as? String ?? "Fail"
            totalResults = response["totalResults"] as? Int ?? 0
            for responseElement in response["articles"] as? [[String: Any?]] ?? [] {
                let articleRemote = ArticleRemote(response: responseElement)
                let article = Article(entity: Article.entity(),
                                      insertInto: context)
                article.setData(articleRemote: articleRemote)
                articles.append(article)
            }
            CoreDataStack.shared.save(context: context)
            hasReachedEnd = (response["articles"] as? [Any])?.isEmpty ?? true
        }
    }
    
    override func requestCompletedSuccessfully() {
        delegate.requestCompletedSuccessfully()
    }
    
    override func requestFailedWith(error: NSError?) {
        delegate.requestFailedWith(error: error)
    }
}
