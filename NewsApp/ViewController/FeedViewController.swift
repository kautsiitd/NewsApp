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
        tableView.contentInset = UIEdgeInsets(top: 4, left: 0, bottom: 20, right: 0)
        
        loader.startAnimating()
        feed.fetch()
    }
}

//MARK: TableView
extension FeedViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feed.articles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FeedTableViewCell") as? FeedTableViewCell else {
            return UITableViewCell()
        }
        cell.delegate = self
        cell.setCell(article: feed.articles[indexPath.row])
        return cell
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
            self?.loader.stopAnimating()
        }
    }
}
