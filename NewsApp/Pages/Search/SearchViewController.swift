//
//  SearchViewController.swift
//  NewsApp
//
//  Created by Kautsya Kanu on 10/01/20.
//  Copyright © 2020 Kautsya Kanu. All rights reserved.
//

import UIKit
import SafariServices

class SearchViewController: UIViewController {
    //MARK: Elements
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var loader: UIActivityIndicatorView!
    
    //MARK: Properties
    private var feed: Search!
    private var currentPage = 1
    private var currentCount = 0
    private var query = "Bitcoin"
    private var timer: Timer?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        feed = Search(delegate: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        fetchFeed()
    }
    
    private func setupTableView() {
        tableView.contentInset = UIEdgeInsets(top: 4, left: 0, bottom: 20, right: 0)
    }
    
    private func fetchFeed() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.currentPage = 1
            self.currentCount = 0
            self.loader.startAnimating()
            self.loader.isHidden = false
            self.feed.fetch(pageNumber: self.currentPage, for: self.query)
            self.tableView.reloadData()
        }
    }
}

//MARK:- TableView
extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var feedCount = feed.articles.count
        if shouldShowLoaderCell() { feedCount+=1 }
        return feedCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row < feed.articles.count {
            let identifier = "\(ArticleTableViewCell.self)"
            let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as! ArticleTableViewCell
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
        return feed.articles.count > 0 && !feed.hasReachedEnd
    }
}

//MARK: UITableViewDelegate
extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let _ = cell as? LoaderTableViewCell else {
            return
        }
        feed.fetch(nextOf: currentPage)
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let article = feed.articles[indexPath.row]
        let share = UIContextualAction(style: .normal, title: "Share", handler: {
            action ,view ,completionHandler in
            self.share(article)
            completionHandler(true)
        })
        share.backgroundColor = .red
        share.image = UIImage(systemName: "square.and.arrow.up")
        
        return UISwipeActionsConfiguration(actions: [share])
    }
    
    private func share(_ article: Article) {
        guard let link = article.newsLink else { return }
        let shareViewController = UIActivityViewController(activityItems: [link], applicationActivities: nil)
        self.present(shareViewController, animated: true, completion: nil)
    }
}

//MARK: ArticleTableViewCellProtocol
extension SearchViewController: ArticleTableViewCellProtocol {
    func open(link: URL) {
        let safariViewController = SFSafariViewController(url: link)
        present(safariViewController, animated: true, completion: nil)
    }
}

//MARK:- API Management
extension SearchViewController: SearchProtocol {
    func didFetchSuccessfully(pageNumber: Int) {
        currentPage = pageNumber
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.loader.stopAnimating()
            self.tableView.insertRows(at: self.newIndexPaths(), with: .automatic)
            self.currentCount = self.feed.articles.count
        }
    }
    
    private func newIndexPaths() -> [IndexPath] {
        var indexPaths: [IndexPath] = []
        var newCount = feed.articles.count
        if currentPage == 1 { newCount += 1 }   //Inserting LoaderCell at end
        if feed.hasReachedEnd { newCount -= 1 } //Removing LoaderCell at end
        for i in currentCount..<newCount {
            let indexPath = IndexPath(row: i, section: 0)
            indexPaths.append(indexPath)
        }
        return indexPaths
    }
    
    func didFail(with error: CustomError) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.loader.stopAnimating()
            
            let retry = CustomAlertAction.retry(self.retryFetching)
            let alert = CustomAlert(with: error, actions: [retry])
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    private func retryFetching() {
        if currentPage == 1 {
            loader.startAnimating()
        }
        feed.fetch(pageNumber: currentPage, for: query)
    }
}

//MARK:- UISearchBar
extension SearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false, block: {
            [weak self] _ in
            self?.query = searchBar.text ?? "Bitcoin"
            self?.fetchFeed()
        })
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
}
