//
//  CoreDataStack.swift
//  NewsApp
//
//  Created by Kautsya Kanu on 06/12/19.
//  Copyright © 2019 Kautsya Kanu. All rights reserved.
//

import Foundation
import CoreData

final class CoreDataManager {
    //MARK: Properties
    static let shared = CoreDataManager()
    private init() {}
    
    private lazy var storeURL = URL.storeURL(for: "group.Kauts.NewsApp", databaseName: "NewsApp")
    
    private lazy var managedObjectModel: NSManagedObjectModel = {
        let bundle = Bundle.main
        let modelURL = bundle.url(forResource: "NewsApp", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    private lazy var container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "NewsApp")
        let options = [NSMigratePersistentStoresAutomaticallyOption: true]
        let coordinator = container.persistentStoreCoordinator
        _ = try? coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: options)
        return container
    }()
    
    lazy var privateContext: NSManagedObjectContext = {
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.persistentStoreCoordinator = container.persistentStoreCoordinator
        return context
    }()
}

//MARK:- Available Functions
extension CoreDataManager {
    func saveAllData() {
        privateContext.perform {
            if self.privateContext.hasChanges {
                try? self.privateContext.save()
            }
        }
    }
    
    func deleteOldData() {
        privateContext.perform {
            let imageDeleteRequest = ArticleCore.deleteAll()
            _ = try? self.privateContext.execute(imageDeleteRequest)
        }
    }
}
