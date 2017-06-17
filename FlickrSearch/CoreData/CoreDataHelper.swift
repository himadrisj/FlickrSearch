//
//  CoreDataHelper.swift
//  FlickrSearch
//
//  Created by Himadri Sekhar Jyoti on 17/06/17.
//  Copyright © 2017 Himadri Jyoti. All rights reserved.
//

import Foundation
import CoreData

final class CoreDataHelper {
    
    static func getNewOrExistingSearchDataAndWait(moc: NSManagedObjectContext) -> SearchData {
        if let existingData = CoreDataHelper.fetchSerachDataAndWait(moc: moc) {
            return existingData
        }
        else {
            let newData = SearchData(managedObjectContext: moc)
            return newData
        }
    }
    
    static func fetchSerachDataAndWait(moc: NSManagedObjectContext) -> SearchData? {
        var searchData: SearchData?
        
        moc.performAndWait {
            let fetchRequest = SearchData.fetchRequestForEntity(inContext: moc)
            
            do {
                let data = try moc.fetch(fetchRequest)
                if data.count > 0 {
                    assert(data.count == 1, "Multiple search data found in DB")
                    searchData = data.first
                }
                
            } catch let error as NSError {
                print("Fetch failed: \(error)")
            }
            
        }
        
        return searchData
    }
    
    static func updateNewOrExistingRecentSearchAndWait(moc: NSManagedObjectContext, searhText: String) {
        moc.performAndWait {
            let searchData = CoreDataHelper.getNewOrExistingSearchDataAndWait(moc: moc)
            
            var matchingSearch: RecentSearch?
            
            if let recentSearches = searchData.recentSearches?.allObjects as? [RecentSearch] {
                for search in recentSearches {
                    if search.searchText == searhText {
                        matchingSearch = search
                        break
                    }
                }
            }
            
            if matchingSearch == nil {
                matchingSearch = RecentSearch(managedObjectContext: moc)
            }
            
            matchingSearch?.searchText = searhText
            matchingSearch?.searchTimeStamp = NSDate()
            
            //Set the relationship
            matchingSearch?.searchData = searchData
            
            CoreDataHelper.ensureMaxRecentSearches(searchData: searchData, moc: moc)
            
            //Save changes
            moc.saveContextToStore()
        }
    }
    
    
    static func ensureMaxRecentSearches(searchData: SearchData, moc: NSManagedObjectContext) {
        guard var recentSearches = searchData.recentSearches?.allObjects as? [RecentSearch] else {
            assert(false, "At least one recent search should be there by this time")
            return
        }
        
        if recentSearches.count > UIConstant.maxRecentSearchCount {
            recentSearches.sort { $0.searchTimeStamp!.timeIntervalSince1970 > $1.searchTimeStamp!.timeIntervalSince1970 }
            
            if let lastSearch = recentSearches.last {
                moc.delete(lastSearch)
            }
        }
    }
}
