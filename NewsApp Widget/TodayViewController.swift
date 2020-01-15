//
//  TodayViewController.swift
//  NewsApp Widget
//
//  Created by Kautsya Kanu on 15/01/20.
//  Copyright © 2020 Kautsya Kanu. All rights reserved.
//

import UIKit
import NotificationCenter
import CoreData

let imageCache = NSCache<NSString, UIImage>()

class TodayViewController: UIViewController, NCWidgetProviding {
    //MARK: Elements
    @IBOutlet private weak var sourceLabel: UILabel!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var imageView: CustomImageView!
    //MARK: Properties
    private var feed: Feed!
    private let numberOfHeadlines = 4
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        imageCache.countLimit = numberOfHeadlines
        feed = Feed(delegate: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        self.feed.fetchCoreData()
    }
    
    private func setupView() {
        preferredContentSize = CGSize(width: 0, height: 200)
        imageView.layer.cornerRadius = 5
    }
}

//MARK: FeedProtocol
extension TodayViewController: FeedProtocol {
    func didFetchSuccessful(of source: Feed.Source) {
        guard let article = feed.articles.first else { return }
        sourceLabel.text = article.author
        titleLabel.text = article.title
        imageView.setImage(with: article.imageLink)
    }
    func didFail(with error: CustomError) {
        print(error.description)
    }
}
