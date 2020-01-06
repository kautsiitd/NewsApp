//
//  FeedTableViewCell.swift
//  NewsApp
//
//  Created by Kautsya Kanu on 02/12/19.
//  Copyright © 2019 Kautsya Kanu. All rights reserved.
//

import UIKit

protocol FeedTableViewCellProtocol {
    func open(link: URL)
}

class FeedTableViewCell: UITableViewCell {
    
    //MARK: Elements
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var linkButton: UIButton!
    @IBOutlet private weak var newsImageView: CustomImageView!
    @IBOutlet private weak var authorLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    
    //MARK: Properties
    var delegate: FeedTableViewCellProtocol?
    private var article: Article?
    
    override func prepareForReuse() {
        titleLabel.text = ""
        linkButton.isEnabled = false
        newsImageView.image = nil
        authorLabel.text = ""
        dateLabel.text = ""
        descriptionLabel.text = ""
    }
}

extension FeedTableViewCell {
    @IBAction func openNews() {
        guard let newsLink = article?.newsLink else { return }
        delegate?.open(link: newsLink)
    }
    
    func setCell(article: Article) {
        self.article = article
        titleLabel.text = article.title
        linkButton.isEnabled = (article.newsLink != nil)
        authorLabel.text = article.author
        dateLabel.text = article.date?.convertTo(string: "yyyy-MM-dd")
        descriptionLabel.text = article.content
        let imageLink = article.imageLink?.absoluteString ?? ""
        newsImageView.setImage(with: imageLink)
    }
}
