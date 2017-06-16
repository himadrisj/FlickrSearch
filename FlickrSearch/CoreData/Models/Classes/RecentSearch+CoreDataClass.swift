//
//  RecentSearch+CoreDataClass.swift
//  
//
//  Created by Himadri Sekhar Jyoti on 17/06/17.
//
//

import Foundation
import CoreData
import BNRCoreDataStack


final class RecentSearch: NSManagedObject, CoreDataModelable {
    static var entityName: String { return "RecentSearch" }
}

