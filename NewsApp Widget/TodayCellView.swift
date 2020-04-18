//
//  TodayCellView.swift
//  NewsApp Widget
//
//  Created by Kautsya Kanu on 15/01/20.
//  Copyright © 2020 Kautsya Kanu. All rights reserved.
//

import UIKit
import CustomImageView

class TodayCellView: UITableViewCell {
    //MARK: Elements
    @IBOutlet private weak var sourceLabel: UILabel!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var customImageView: CustomImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        customImageView.layer.cornerRadius = 5
    }
}

extension TodayCellView {
    func setCell(with article: Article) {
        sourceLabel.text = article.source.name
        titleLabel.text = article.title
        customImageView.setImage(with: article.imageLink)
    }
}
