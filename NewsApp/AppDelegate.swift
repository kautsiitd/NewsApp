//
//  AppDelegate.swift
//  NewsApp
//
//  Created by Kautsya Kanu on 30/11/19.
//  Copyright © 2019 Kautsya Kanu. All rights reserved.
//

import UIKit

let imageCache = NSCache<NSString, UIImage>()

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        imageCache.countLimit = 40
        return true
    }
}

