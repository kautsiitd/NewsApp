//
//  LoaderTableViewCell.swift
//  NewsApp
//
//  Created by Kautsya Kanu on 03/12/19.
//  Copyright © 2019 Kautsya Kanu. All rights reserved.
//

import UIKit

class LoaderTableViewCell: UITableViewCell {
    
    //MARK: Properties
    private var loader: UIActivityIndicatorView!
    
    func addLoader() {
        loader = UIActivityIndicatorView(style: .medium)
        loader.center = contentView.center
        loader.isHidden = false
        loader.startAnimating()
        contentView.addSubview(loader)
    }
}
