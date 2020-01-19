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
    private let context: NSManagedObjectContext = {
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.parent = CoreDataStack.shared.context
        return context
    }()
    private var delegate: FeedProtocol
    private var totalResults: Int = 0
    private var fetchedPage: Int = 0
    
    var articles: [Article] = []
    var hasReachedEnd: Bool = false
    
    init(delegate: FeedProtocol) {
        self.delegate = delegate
    }
    
    //MARK: ApiManagement
    override func apiEndPoint() -> String {
        return "v2/top-headlines"
    }
    
    override func parse(_ response: [String : Any]) {
        _ = response["status"] as? String ?? "Fail"
        totalResults = response["totalResults"] as? Int ?? 0
        
        let remoteArticlesDict = response["articles"] as? [[String: Any?]] ?? []
        parse(remoteArticlesDict)
        
        hasReachedEnd = totalResults == articles.count
    }
    
    private func parse(_ remoteArticlesDict: [[String: Any?]]) {
        var remoteArticles: [ArticleRemote] = []
        for remoteArticleDict in remoteArticlesDict {
            let articleRemote = ArticleRemote(response: remoteArticleDict)
            remoteArticles.append(articleRemote)
        }
        for articleRemote in remoteArticles {
            let article = Article(context: context)
            article.setData(articleRemote: articleRemote)
            articles.append(article)
        }
        try? context.save()
    }
    
    private func deleteOld() {
        CustomImageView.clearOldData()
        let articlesDeleteRequest = Article.deleteAll()
        _ = try? context.execute(articlesDeleteRequest)
    }
    
    override func didFetchSuccessfully() {
        //Delete old coreData only when there is new feed fetch data is available
        if fetchedPage == 1 { deleteOld() }
        delegate.didFetchSuccessful(of: .remote(pageNumber: fetchedPage))
    }
    
    override func didFail(with error: CustomError) {
        delegate.didFail(with: error)
    }
}

//MARK: Available functions
extension Feed {
    func fetchCoreData() {
        articles = (try? context.fetch(Article.fetchAll())) ?? []
        if articles.isEmpty {
            delegate.didFail(with: .retryRemote)
        } else {
            hasReachedEnd = true
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
        let params: [String: Any] = ["country": "us", "page": pageNumber]
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
