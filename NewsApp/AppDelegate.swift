//
//  AppDelegate.swift
//  NewsApp
//
//  Created by Kautsya Kanu on 30/11/19.
//  Copyright © 2019 Kautsya Kanu. All rights reserved.
//

import UIKit
import CoreData

let imageCache = NSCache<NSString, UIImage>()

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    lazy var persistentContainer: NSPersistentContainer = {
      let container = NSPersistentContainer(name: "NewsApp")
      container.loadPersistentStores(completionHandler: {
        (storeDescription, error) in
          print(storeDescription)
          if let error = error as NSError? {
            fatalError("Unresolved error \(error), \(error.userInfo)")
          }
      })
      return container
    }()
    
    func saveContext() {
      let context = persistentContainer.viewContext
      if context.hasChanges {
        do {
          try context.save()
        } catch {
          let error = error as NSError
          fatalError("Unresolved error \(error), \(error.userInfo)")
        }
      }
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        imageCache.countLimit = 40
        return true
    }
}

