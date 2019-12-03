//
//  Feed.swift
//  NewsApp
//
//  Created by Kautsya Kanu on 02/12/19.
//  Copyright © 2019 Kautsya Kanu. All rights reserved.
//

import Foundation

protocol FeedProtocol {
    func requestCompletedSuccessfully()
    func requestFailedWith(error: NSError?)
}

class Feed: BaseClass {
    //MARK: Properties
    private var status: String = "Fail"
    private var totalResults: Int = 0
    var articles: [Article] = []
    private var delegate: FeedProtocol
    
    init(delegate: FeedProtocol) {
        self.delegate = delegate
    }
    
    //MARK: Available Functions
    func fetch() {
        let params: [String: Any] = ["country": "us",
                                     "page": 2]
        ApiManager.shared.getRequestWith(params: params,
                                         delegate: self)
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
            articles.append(article)
        }
    }
    
    override func requestCompletedSuccessfully() {
        delegate.requestCompletedSuccessfully()
    }
    
    override func requestFailedWith(error: NSError?) {
        delegate.requestFailedWith(error: error)
    }
}
