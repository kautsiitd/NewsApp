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
        guard let url = article?.url else {
            return
        }
        delegate?.open(link: url)
    }
    
    func setCell(article: Article) {
        self.article = article
        titleLabel.text = article.title
        linkButton.isEnabled = (article.url != nil)
        authorLabel.text = article.author
        let date = String(article.publishedAt.split(separator: "T")[0])
        dateLabel.text = date
        descriptionLabel.text = article.newsDescription
        let imageURL = article.urlToImage
        newsImageView.getImageWith(imageURL,
                                   handleLoader: true,
                                   placeHolderImage: nil,
                                   completion: { [weak self] image, url, type in
                                    if (imageURL?.absoluteString == self?.article?.urlToImage?.absoluteString) {
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
