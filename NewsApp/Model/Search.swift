//
//  Search.swift
//  NewsApp
//
//  Created by Kautsya Kanu on 10/01/20.
//  Copyright © 2020 Kautsya Kanu. All rights reserved.
//

import CoreData

protocol SearchProtocol {
    func didFetchSuccessfully(pageNumber: Int)
    func didFail(with error: CustomError)
}

class Search: BaseClass {
    //MARK: Properties
    private let context: NSManagedObjectContext = {
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.parent = CoreDataStack.shared.context
        return context
    }()
    private var delegate: SearchProtocol
    private var totalResults: Int = 0
    private var fetchedPage: Int = 0
    private var query: String = ""
    
    var articles: [Article] = []
    var hasReachedEnd: Bool = false
    
    init(delegate: SearchProtocol) {
        self.delegate = delegate
    }
    
    //MARK: ApiManagement
    override func apiEndPoint() -> String {
        return "v2/everything"
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
    }
    
    override func didFetchSuccessfully() {
        delegate.didFetchSuccessfully(pageNumber: fetchedPage)
    }
    
    override func didFail(with error: CustomError) {
        delegate.didFail(with: error)
    }
}

//MARK: Available functions
extension Search {
    func fetch(nextOf pageNumber: Int) {
        if fetchedPage == pageNumber + 1 { return } //Requesting to fetch same page again
        fetch(pageNumber: pageNumber + 1, for: query)
    }
    
    func fetch(pageNumber: Int, for query: String) {
        if pageNumber == 1 {
            self.query = query
            articles = []
        }
        fetchedPage = pageNumber
        let params = getParams(for: query, pageNumber: pageNumber)
        ApiManager.shared.getRequest(for: params, self)
    }
    
    private func getParams(for query: String, pageNumber: Int) -> [String: Any] {
        var dict: [String: Any] = [:]
        dict["q"] = query
        dict["page"] = pageNumber
        dict["sortBy"] = "publishedAt"
        return dict
    }
}
