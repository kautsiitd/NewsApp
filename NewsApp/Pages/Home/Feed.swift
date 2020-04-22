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
import CustomImageView

protocol FeedProtocol {
    func didFetchSuccessful(of source: Feed.Source)
    func didFail(with error: CustomError)
}

class Feed: BaseClass {
    enum Source {
        case coreData
        case remote(pageNumber: Int)
    }
    //MARK: Properties
    private var delegate: FeedProtocol
    private var totalResults: Int = 0
    private var fetchedPage: Int = 0
    var context: NSManagedObjectContext = {
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.parent = CoreDataManager.shared.privateContext
        return context
    }()
    
    var articles: [Article] = []
    var hasReachedEnd: Bool = false
    
    init(delegate: FeedProtocol) {
        self.delegate = delegate
    }
    
    //MARK: ApiManagement
    override func apiEndPoint() -> String {
        return "v2/top-headlines"
    }
    
    override func parse(_ response: [String : Any], for params: [String: Any]) {
        _ = response["status"] as? String ?? "Fail"
        totalResults = response["totalResults"] as? Int ?? 0
        
        let articlesDict = response["articles"] as? [[String: Any?]] ?? []
        parse(articlesDict)
        
        hasReachedEnd = totalResults == articles.count
    }
    
    private func parse(_ articlesDict: [[String: Any?]]) {
        var newArticles: [Article] = []
        for articleDict in articlesDict {
            let article = Article(response: articleDict)
            newArticles.append(article)
        }
        articles.append(contentsOf: newArticles)
        
        context.perform {
            if self.fetchedPage == 1 {
                self.deleteOld()
            }
            for article in newArticles {
                let articleCore = ArticleCore(context: self.context)
                articleCore.setData(article)
            }
            self.saveAllData()
        }
    }
    
    private func saveAllData() {
        try? self.context.save()
        CoreDataManager.shared.saveAllData()
    }
    
    private func deleteOld() {
        CustomImageView.clearOldData()
        let articlesDeleteRequest = ArticleCore.deleteAll()
        _ = try? context.execute(articlesDeleteRequest)
    }
    
    override func didFetchSuccessfully(for params: [String: Any]) {
        delegate.didFetchSuccessful(of: .remote(pageNumber: fetchedPage))
    }
    
    override func didFail(with error: CustomError) {
        delegate.didFail(with: error)
    }
}

//MARK: Available functions
extension Feed {
    func fetchCoreData() {
        let coreArticles = (try? context.fetch(ArticleCore.fetchAll())) ?? []
        if coreArticles.isEmpty {
            delegate.didFail(with: .retryRemote)
        } else {
            hasReachedEnd = true
            for coreArticle in coreArticles {
                let article = Article(article: coreArticle)
                articles.append(article)
            }
            delegate.didFetchSuccessful(of: .coreData)
        }
    }
    
    func fetch(nextOf pageNumber: Int) {
        if fetchedPage == pageNumber + 1 { return } //Requesting to fetch same page again
        fetch(pageNumber: pageNumber + 1)
    }
    
    func fetch(pageNumber: Int) {
        if pageNumber <= 1 { articles = [] }
        fetchedPage = pageNumber
        let params: [String: Any] = ["country": "in", "page": pageNumber]
        ApiManager.shared.getRequest(for: params, self)
    }
}

//MARK: Feed Source
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
