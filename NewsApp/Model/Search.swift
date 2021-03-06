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
    
    override func parse(_ response: [String : Any], for params: [String: Any]) {
        _ = response["status"] as? String ?? "Fail"
        
        let articlesDict = response["articles"] as? [[String: Any?]] ?? []
        if isLatest(params) {
            DispatchQueue.main.async {
                self.totalResults = response["totalResults"] as? Int ?? 0
                self.parse(articlesDict)
                self.hasReachedEnd = self.totalResults == self.articles.count
            }
        }
    }
    
    private func isLatest(_ params: [String: Any]) -> Bool {
        let queryFetched = params["q"] as? String
        let urlQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        return queryFetched == urlQuery
    }
    
    private func parse(_ articlesDict: [[String: Any?]]) {
        for articleDict in articlesDict {
            let article = Article(response: articleDict)
            articles.append(article)
        }
    }
    
    override func didFetchSuccessfully(for params: [String : Any]) {
        if isLatest(params) {
            delegate.didFetchSuccessfully(pageNumber: fetchedPage)
        }
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
            articles.removeAll()
        }
        fetchedPage = pageNumber
        let params = getParams(for: query, pageNumber: pageNumber)
        ApiManager.shared.getRequest(for: params, self)
    }
    
    private func getParams(for query: String, pageNumber: Int) -> [String: Any] {
        var dict: [String: Any] = [:]
        dict["q"] = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        dict["page"] = pageNumber
        dict["sortBy"] = "publishedAt"
        return dict
    }
}
