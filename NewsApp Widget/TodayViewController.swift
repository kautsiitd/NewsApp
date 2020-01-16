//
//  TodayViewController.swift
//  NewsApp Widget
//
//  Created by Kautsya Kanu on 15/01/20.
//  Copyright © 2020 Kautsya Kanu. All rights reserved.
//

import UIKit
import NotificationCenter

let imageCache = NSCache<NSString, UIImage>()

class TodayViewController: UIViewController {
    //MARK: Elements
    @IBOutlet private weak var loader: UIActivityIndicatorView!
    @IBOutlet private weak var tableView: UITableView!
    //MARK: Properties
    private var feed: Feed!
    private let numberOfHeadlines = 3
    private var currentState: NCWidgetDisplayMode = .compact
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        imageCache.countLimit = 40
        feed = Feed(delegate: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        DispatchQueue.main.async {
            self.loader.startAnimating()
            self.feed.fetchCoreData()
        }
    }
}

//MARK:- NCWidgetProviding
extension TodayViewController: NCWidgetProviding {
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        currentState = activeDisplayMode
        refreshView()
    }
    
    private func refreshView() {
        tableView.reloadData()
        tableView.layoutIfNeeded()
        var size = tableView.contentSize
        size.height += 8
        preferredContentSize = size
    }
}

//MARK:- TableView
extension TodayViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch currentState {
        case .compact:
            return min(1, feed.articles.count)
        default:
            return min(numberOfHeadlines, feed.articles.count)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "\(TodayCellView.self)"
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as! TodayCellView
        let article = feed.articles[indexPath.row]
        cell.setCell(with: article)
        return cell
    }
}

extension TodayViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let _ = feed.articles[indexPath.row]
    }
}

//MARK:- FeedProtocol
extension TodayViewController: FeedProtocol {
    func didFetchSuccessful(of source: Feed.Source) {
        DispatchQueue.main.async { [weak self] in
            self?.loader.stopAnimating()
            self?.refreshView()
        }
    }
    func didFail(with error: CustomError) {
        print(error.description)
    }
}
