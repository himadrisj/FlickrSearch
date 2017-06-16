//
//  RecentSearch+CoreDataProperties.swift
//  
//
//  Created by Himadri Sekhar Jyoti on 17/06/17.
//
//

import Foundation
import CoreData


extension RecentSearch {

    @NSManaged var searchText: String?
    @NSManaged var searchTimeStamp: NSDate?
    @NSManaged var searchData: SearchData?

}

