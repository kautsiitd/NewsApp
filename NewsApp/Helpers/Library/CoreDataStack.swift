//
//  CoreDataStack.swift
//  NewsApp
//
//  Created by Kautsya Kanu on 06/12/19.
//  Copyright © 2019 Kautsya Kanu. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    //MARK: Properties
    static let shared = CoreDataStack()
    private init() {}
    let modelName = "NewsApp"
    
    lazy var context:NSManagedObjectContext = {
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    lazy var coordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        var storeURL = appDocumentDirectory
        storeURL.appendPathComponent(modelName)
        let options = [NSMigratePersistentStoresAutomaticallyOption: true]
        _ = try? coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: options)
        return coordinator
    }()
    
    lazy var appDocumentDirectory: URL = {
        let fileManager = FileManager.default
        if let url = fileManager.containerURL(forSecurityApplicationGroupIdentifier: "group.Kauts.NewsApp") {
            return url
        }
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        return urls.first!
    }()
    
    var managedObjectModel: NSManagedObjectModel = {
        let bundle = Bundle.main
        let modelURL = bundle.url(forResource: "NewsApp", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
}
