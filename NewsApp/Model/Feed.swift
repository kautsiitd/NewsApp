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

protocol FeedProtocol {
    func requestCompletedSuccessfully(of source: Feed.Source)
    func requestFailedWith(error: CustomError)
}

class Feed: BaseClass {
    enum Source {
        case coreData
        case remote(pageNumber: Int)
    }
    //MARK: Properties
    private let context: NSManagedObjectContext = {
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.parent = CoreDataStack.shared.persistentContainer.viewContext
        return context
    }()
    
    private var totalResults: Int = 0
    private var fetchedPage: Int = 0
    var articles: [Article] = []
    private var delegate: FeedProtocol
    var hasReachedEnd: Bool = false
    
    var lastCount: Int = 0
    var newCount: Int = 0
    
    init(delegate: FeedProtocol) {
        self.delegate = delegate
    }
    
    //MARK: ApiManagement
    override func getApiEndPoint() -> String {
        return "top-headlines"
    }
    
    override func parse(response: [String : Any]) {
        _ = response["status"] as? String ?? "Fail"
        totalResults = response["totalResults"] as? Int ?? 0
        
        var remoteArticles: [ArticleRemote] = []
        for articleRemoteDict in response["articles"] as? [[String: Any?]] ?? [] {
            let articleRemote = ArticleRemote(response: articleRemoteDict)
            remoteArticles.append(articleRemote)
        }
        for articleRemote in remoteArticles {
            let article = Article(context: context)
            article.setData(articleRemote: articleRemote)
            articles.append(article)
        }
        try? context.save()
        
        hasReachedEnd = totalResults == articles.count
    }
    
    private func deleteOld() {
        let imageDeleteRequest = Image.deleteAll()
        _ = try? context.execute(imageDeleteRequest)
        let articlesDeleteRequest = Article.deleteAll()
        _ = try? context.execute(articlesDeleteRequest)
    }
    
    override func requestCompletedSuccessfully() {
        //Delete old coreData only when there is new feed fetch data is available
        if fetchedPage == 1 { deleteOld() }
        delegate.requestCompletedSuccessfully(of: .remote(pageNumber: fetchedPage))
    }
    
    override func requestFailedWith(error: CustomError) {
        delegate.requestFailedWith(error: error)
    }
}

extension Feed {
    func fetchCoreData() {
        articles = []
        do {
            articles = try context.fetch(Article.fetchAll())
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        if articles.isEmpty {
            delegate.requestFailedWith(error: .retryRemote)
        } else {
            hasReachedEnd = true
            delegate.requestCompletedSuccessfully(of: .coreData)
        }
    }
    
    func fetch(nextOf pageNumber: Int) {
        if fetchedPage == pageNumber + 1 { return } //Requesting to fetch same page again
        fetch(pageNumber: pageNumber + 1)
    }
    
    func fetch(pageNumber: Int) {
        if pageNumber == 1 { articles = [] }
        fetchedPage = pageNumber
        let params: [String: Any] = ["country": "us", "page": pageNumber]
        ApiManager.shared.getRequestWith(params: params, delegate: self)
    }
}

extension Feed.Source {
    static func ==(lhs: Feed.Source, rhs: Feed.Source) -> Bool {
        switch (lhs,rhs) {
        case (.coreData, .coreData):
            return true
        case (.remote(_), .remote(_)):
            return true
        default:
            return false
        }
    }
    
    static func !=(lhs: Feed.Source, rhs: Feed.Source) -> Bool {
        return !(lhs == rhs)
    }
}
