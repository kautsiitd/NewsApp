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
    @IBOutlet private weak var refreshButton: UIBarButtonItem!
    private var refreshControl: UIRefreshControl!
    
    //MARK: Properties
    private var feed: Feed!
    private var feedSource = Feed.Source.coreData
    private var currentPage = 1
    private var currentCount = 0
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        feed = Feed(delegate: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 4, left: 0, bottom: 20, right: 0)
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView?.addSubview(refreshControl)
        
        loader.startAnimating()
        DispatchQueue.main.async {
            self.feed.fetchCoreData()
        }
    }
}

//MARK: IBOutlets
extension FeedViewController {
    @IBAction private func refresh() {
        currentPage = 1
        currentCount = 0
        refreshButton.isEnabled = false
        feed.fetch(pageNumber: currentPage)
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
            self?.loader.startAnimating()
        }
    }
}

//MARK: TableView
extension FeedViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var feedCount = feed.articles.count
        if shouldShowLoaderCell() { feedCount+=1 }
        return feedCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row < feed.articles.count {
            let identifier = "\(FeedTableViewCell.self)"
            let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as! FeedTableViewCell
            cell.delegate = self
            cell.setCell(article: feed.articles[indexPath.row])
            return cell
        }
        else if shouldShowLoaderCell() {
            let identifier = "\(LoaderTableViewCell.self)"
            let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as! LoaderTableViewCell
            return cell
        }
        return UITableViewCell()
    }
    
    private func shouldShowLoaderCell() -> Bool {
        return feedSource != .coreData && feed.articles.count > 0 && !feed.hasReachedEnd
    }
}

//MARK: UITableViewDelegate
extension FeedViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let _ = cell as? LoaderTableViewCell else {
            return
        }
        feed.fetch(nextOf: currentPage)
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
    func requestCompletedSuccessfully(of source: Feed.Source) {
        feedSource = source
        switch source {
        case .remote(let fetchedPage):
            currentPage = fetchedPage
        default:
            break
        }
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.loader.stopAnimating()
            self.refreshControl.endRefreshing()
            self.tableView.insertRows(at: self.newIndexPaths(), with: .automatic)
            self.refreshButton.isEnabled = true
            self.currentCount = self.feed.articles.count
        }
    }
    
    private func newIndexPaths() -> [IndexPath] {
        var indexPaths: [IndexPath] = []
        var newCount = feed.articles.count
        if feedSource == .remote(pageNumber: -1) {
            if currentPage == 1 { newCount += 1 }   //Inserting LoaderCell at end
            if feed.hasReachedEnd { newCount -= 1 } //Removing LoaderCell at end
        }
        for i in currentCount..<newCount {
            let indexPath = IndexPath(row: i, section: 0)
            indexPaths.append(indexPath)
        }
        return indexPaths
    }
    
    func requestFailedWith(error: CustomError) {
        switch error {
        case .retryRemote:
            feed.fetch(pageNumber: currentPage)
        default:
            DispatchQueue.main.async { [weak self] in
                self?.loader.stopAnimating()
                self?.refreshControl.endRefreshing()
                self?.showAlert(error: error)
            }
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
