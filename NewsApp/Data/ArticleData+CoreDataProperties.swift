//
//  ArticleData+CoreDataProperties.swift
//  NewsApp
//
//  Created by Kautsya Kanu on 03/12/19.
//  Copyright © 2019 Kautsya Kanu. All rights reserved.
//
//

import Foundation
import CoreData


extension ArticleData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ArticleData> {
        return NSFetchRequest<ArticleData>(entityName: "ArticleData")
    }

    @NSManaged public var title: String?

}
