//
//  TodayViewController.swift
//  NewsApp Widget
//
//  Created by Kautsya Kanu on 15/01/20.
//  Copyright © 2020 Kautsya Kanu. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
    //MARK: Elements
    @IBOutlet private weak var sourceLabel: UILabel!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    private func setupView() {
        preferredContentSize = CGSize(width: 0, height: 200)
        imageView.layer.cornerRadius = 5
    }
}
