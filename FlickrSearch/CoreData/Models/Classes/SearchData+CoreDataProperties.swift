//
//  SearchData+CoreDataProperties.swift
//  
//
//  Created by Himadri Sekhar Jyoti on 17/06/17.
//
//

import Foundation
import CoreData


extension SearchData {
    @NSManaged var recentSearches: NSSet?

}

// MARK: Generated accessors for recentSearches
extension SearchData {

    @objc(addRecentSearchesObject:)
    @NSManaged func addToRecentSearches(_ value: RecentSearch)

    @objc(removeRecentSearchesObject:)
    @NSManaged func removeFromRecentSearches(_ value: RecentSearch)

    @objc(addRecentSearches:)
    @NSManaged func addToRecentSearches(_ values: NSSet)

    @objc(removeRecentSearches:)
    @NSManaged func removeFromRecentSearches(_ values: NSSet)

}
