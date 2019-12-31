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
    func requestCompletedSuccessfully()
    func requestFailedWith(error: CustomError)
}

class Feed: BaseClass {
    //MARK: Properties
    private let context: NSManagedObjectContext = {
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.parent = CoreDataStack.shared.persistentContainer.viewContext
        return context
    }()
    
    private var status: String = "Fail"
    private var totalResults: Int = 0
    private var fetchPage: Int = 0
    var articles: [Article] = []
    private var delegate: FeedProtocol
    var hasReachedEnd: Bool = false
    
    init(delegate: FeedProtocol) {
        self.delegate = delegate
    }
    
    //MARK: ApiManagement
    override func getApiEndPoint() -> String {
        return "top-headlines"
    }
    
    override func parse(response: [String : Any]) {
        status = response["status"] as? String ?? "Fail"
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
        
        hasReachedEnd = (response["articles"] as? [Any])?.isEmpty ?? true
    }
    
    private func deleteOld() {
        let imageDeleteRequest = Image.deleteAll()
        _ = try? context.execute(imageDeleteRequest)
        let articlesDeleteRequest = Article.deleteAll()
        _ = try? context.execute(articlesDeleteRequest)
    }
    
    override func requestCompletedSuccessfully() {
        //Delete old coreData only when there is new feed fetch data is available
        if fetchPage == 1 { deleteOld() }
        delegate.requestCompletedSuccessfully()
    }
    
    override func requestFailedWith(error: CustomError) {
        delegate.requestFailedWith(error: error)
    }
}

extension Feed {
    func fetch(pageNumber: Int, ifPossibleCoreData: Bool = false) {
        fetchPage = pageNumber
        if pageNumber == 1 {
            articles = []
            if ifPossibleCoreData {
                fetchCoreData()
                if !articles.isEmpty {
                    hasReachedEnd = true
                    delegate.requestCompletedSuccessfully()
                    return
                }
            }
        }
        let params: [String: Any] = ["country": "us", "page": pageNumber]
        ApiManager.shared.getRequestWith(params: params, delegate: self)
    }
    
    private func fetchCoreData() {
        do {
            articles = try context.fetch(Article.fetchAll())
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
}
