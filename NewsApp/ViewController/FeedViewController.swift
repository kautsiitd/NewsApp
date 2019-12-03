//
//  FeedViewController.swift
//  NewsApp
//
//  Created by Kautsya Kanu on 30/11/19.
//  Copyright © 2019 Kautsya Kanu. All rights reserved.
//

import Foundation
import UIKit
import SafariServices

class FeedViewController: UIViewController {
    
    //MARK: Elements
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var loader: UIActivityIndicatorView!
    private var feed: Feed!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        feed = Feed(delegate: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 4, left: 0, bottom: 0, right: 0)
        tableView.register(LoaderTableViewCell.self, forCellReuseIdentifier: "LoaderTableViewCell")
        
        loader.startAnimating()
        feed.fetch(nextPage: true)
    }
}

//MARK: TableView
extension FeedViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feed.articles.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row < feed.articles.count {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "FeedTableViewCell") as? FeedTableViewCell else {
                return UITableViewCell()
            }
            cell.delegate = self
            cell.setCell(article: feed.articles[indexPath.row])
            return cell
        }
        else if feed.articles.count > 0 && !feed.hasReachedEnd {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "LoaderTableViewCell") as? LoaderTableViewCell else {
                return UITableViewCell()
            }
            cell.addLoader()
            return cell
        }
        return UITableViewCell()
    }
}

extension FeedViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == feed.articles.count && !feed.hasReachedEnd {
            feed.fetch(nextPage: true)
        }
    }
}

//MARK: FeedTableViewCellProtocol
extension FeedViewController: FeedTableViewCellProtocol {
    func open(link: URL) {
        let safariViewController = SFSafariViewController(url: link)
        present(safariViewController,
                animated: true,
                completion: nil)
    }
}

//MARK: API Management
extension FeedViewController: FeedProtocol {
    func requestCompletedSuccessfully() {
        DispatchQueue.main.async { [weak self] in
            self?.loader.stopAnimating()
            self?.tableView.reloadData()
        }
    }
    
    func requestFailedWith(error: NSError?) {
        DispatchQueue.main.async { [weak self] in
            self?.loader.startAnimating()
            let alertViewController = UIAlertController(title: error?.domain,
                                                        message: error?.localizedDescription,
                                                        preferredStyle: .alert)
            let retryButton = UIAlertAction(title: "Retry",
                                            style: .default,
                                            handler: { _ in
                                                self?.feed.fetch(nextPage: false)
            })
            alertViewController.addAction(retryButton)
            self?.present(alertViewController,
                          animated: true,
                          completion: nil)
        }
    }
}
