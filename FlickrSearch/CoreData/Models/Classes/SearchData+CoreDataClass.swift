//
//  SearchData+CoreDataClass.swift
//  
//
//  Created by Himadri Sekhar Jyoti on 17/06/17.
//
//

import Foundation
import CoreData
import BNRCoreDataStack

final class SearchData: NSManagedObject, CoreDataModelable {
    static var entityName: String { return "SearchData" }
}
