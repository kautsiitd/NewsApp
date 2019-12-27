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
    private var refreshControl: UIRefreshControl!
    
    //MARK: Properties
    private var feed: Feed!
    private var currentPage: Int = 1
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        feed = Feed(delegate: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 4, left: 0, bottom: 0, right: 0)
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView?.addSubview(refreshControl)
        
        loader.startAnimating()
        feed.fetch(pageNumber: currentPage, ifPossibleCoreData: true)
    }
}

//MARK: IBOutlets
extension FeedViewController {
    @IBAction private func refresh() {
        currentPage = 1
        feed.fetch(pageNumber: currentPage)
        DispatchQueue.main.async { [weak self] in
            self?.loader.startAnimating()
            self?.tableView.reloadData()
        }
    }
}

//MARK: TableView
extension FeedViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feed.articles.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row < feed.articles.count {
            let identifier = "\(FeedTableViewCell.self)"
            let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as! FeedTableViewCell
            cell.delegate = self
            cell.setCell(article: feed.articles[indexPath.row])
            return cell
        }
        else if feed.articles.count > 0 && !feed.hasReachedEnd {
            let identifier = "\(LoaderTableViewCell.self)"
            let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as! LoaderTableViewCell
            return cell
        }
        return UITableViewCell()
    }
}

extension FeedViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if isMoreToFetchAt(indexPath: indexPath) {
            currentPage += 1
            feed.fetch(pageNumber: currentPage)
        }
    }
    
    private func isMoreToFetchAt(indexPath: IndexPath) -> Bool {
        return indexPath.row == feed.articles.count && !feed.hasReachedEnd
    }
}

//MARK: FeedTableViewCellProtocol
extension FeedViewController: FeedTableViewCellProtocol {
    func open(link: URL) {
        let safariViewController = SFSafariViewController(url: link)
        present(safariViewController, animated: true, completion: nil)
    }
}

//MARK: API Management
extension FeedViewController: FeedProtocol {
    func requestCompletedSuccessfully() {
        DispatchQueue.main.async { [weak self] in
            self?.loader.stopAnimating()
            self?.refreshControl.endRefreshing()
            self?.tableView.reloadData()
        }
    }
    
    func requestFailedWith(error: CustomError) {
        DispatchQueue.main.async { [weak self] in
            self?.loader.stopAnimating()
            self?.refreshControl.endRefreshing()
            self?.showAlert(error: error)
        }
    }
    
    private func showAlert(error: CustomError) {
        let alertViewController = UIAlertController(title: error.title, message: error.description,
                                                    preferredStyle: .alert)
        let retryButton = UIAlertAction(title: "Retry", style: .default, handler: { [weak self] _ in
            self?.retryFetching()
        })
        alertViewController.addAction(retryButton)
        present(alertViewController, animated: true, completion: nil)
    }
    
    private func retryFetching() {
        if currentPage == 1 {
            loader.startAnimating()
        }
        feed.fetch(pageNumber: currentPage)
    }
}
