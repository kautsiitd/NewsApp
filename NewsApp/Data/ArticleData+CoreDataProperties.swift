//
//  ArticleData+CoreDataProperties.swift
//  NewsApp
//
//  Created by Kautsya Kanu on 04/12/19.
//  Copyright © 2019 Kautsya Kanu. All rights reserved.
//
//

import Foundation
import CoreData


extension ArticleData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ArticleData> {
        return NSFetchRequest<ArticleData>(entityName: "ArticleData")
    }

    @NSManaged public var author: String?
    @NSManaged public var content: String?
    @NSManaged public var date: String?
    @NSManaged public var newsDescription: String?
    @NSManaged public var title: String?
    @NSManaged public var url: String?
    @NSManaged public var urlToImage: String?

}
