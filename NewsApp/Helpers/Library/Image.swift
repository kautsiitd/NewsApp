//
//  Image.swift
//  NewsApp
//
//  Created by Kautsya Kanu on 31/12/19.
//  Copyright © 2019 Kautsya Kanu. All rights reserved.
//

import Foundation
import CoreData

class Image: NSManagedObject {
    //MARK: Properties
    @NSManaged var urlString: String
    @NSManaged var data: NSData?
    
    @nonobjc class func fetchAll() -> NSFetchRequest<Image> {
        return NSFetchRequest<Image>(entityName: "\(Image.self)")
    }
    
    @nonobjc class func deleteAll() -> NSBatchDeleteRequest {
        let fetchRequest = NSFetchRequest<Image>(entityName: "\(Image.self)")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest as! NSFetchRequest<NSFetchRequestResult>)
        return deleteRequest
    }
}
