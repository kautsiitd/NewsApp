//
//  LoaderTableViewCell.swift
//  NewsApp
//
//  Created by Kautsya Kanu on 03/12/19.
//  Copyright © 2019 Kautsya Kanu. All rights reserved.
//

import UIKit

class LoaderTableViewCell: UITableViewCell {
    //MARK: Elements
    @IBOutlet private weak var loader: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        loader.startAnimating()
    }
}
