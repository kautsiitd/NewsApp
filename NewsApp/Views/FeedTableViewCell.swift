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
    @IBOutlet private weak var newsImageView: UIImageView!
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
        guard let newsLink = article?.newsLink else {
            return
        }
        delegate?.open(link: newsLink)
    }
    
    func setCell(article: Article) {
        self.article = article
        titleLabel.text = article.title
        linkButton.isEnabled = (article.newsLink != nil)
        authorLabel.text = article.author
        dateLabel.text = article.publishedAt?.convertTo(string: "yyyy-MM-dd")
        descriptionLabel.text = article.description
        let imageLink = article.imageLink
        newsImageView.getImageWith(article.imageLink, handleLoader: true, placeHolderImage: nil,
                                   completion: { [weak self] image, url, type in
                                    if url == imageLink {
                                        guard let image = image else {
                                            self?.newsImageView.assignImage(image: #imageLiteral(resourceName: "NoImage.png"))
                                            return
                                        }
                                        switch type {
                                        case .downloaded:
                                            self?.newsImageView.animate(image: image,
                                                                        withAnimation: .transitionCrossDissolve)
                                        default:
                                            self?.newsImageView.assignImage(image: image)
                                        }
                                    }
        })
    }
}
