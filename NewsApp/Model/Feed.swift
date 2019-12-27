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
    func requestFailedWith(error: CustomError)
}

class Feed: BaseClass {
    //MARK: Properties
    let context = CoreDataStack.shared.persistentContainer.viewContext
    
    private var status: String = "Fail"
    private var totalResults: Int = 0
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
        for articleDict in response["articles"] as? [[String: Any?]] ?? [] {
            let article = Article(response: articleDict)
            articles.append(article)
        }
        hasReachedEnd = (response["articles"] as? [Any])?.isEmpty ?? true
        updateCoreData()
    }
    
    private func updateCoreData() {
        DispatchQueue.main.async { [unowned self] in
            for article in self.articles {
                let articleCore = ArticleCore(context: self.context)
                articleCore.setData(article: article)
            }
            if !self.articles.isEmpty { self.deleteOld() }
            CoreDataStack.shared.save(context: self.context)
        }
    }
    
    private func deleteOld() {
        CoreDataStack.shared.delete(entityName: "\(ArticleCore.self)")
    }
    
    override func requestCompletedSuccessfully() {
        delegate.requestCompletedSuccessfully()
    }
    
    override func requestFailedWith(error: CustomError) {
        delegate.requestFailedWith(error: error)
    }
}

extension Feed {
    func fetch(pageNumber: Int, ifPossibleCoreData: Bool = false) {
        if pageNumber == 1 || ifPossibleCoreData {
            articles = []
        }
        if ifPossibleCoreData {
            fetchCoreData()
            if !articles.isEmpty {
                hasReachedEnd = true
                delegate.requestCompletedSuccessfully()
                return
            }
        }
        let params: [String: Any] = ["country": "us", "page": pageNumber]
        ApiManager.shared.getRequestWith(params: params, delegate: self)
    }
    
    private func fetchCoreData() {
        do {
            let coreArticles = try context.fetch(ArticleCore.fetchAll())
            for articleCore in coreArticles {
                let article = Article(articleCore: articleCore)
                articles.append(article)
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
}
