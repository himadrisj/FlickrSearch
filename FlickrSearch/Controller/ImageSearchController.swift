//
//  ImageSearchController.swift
//  FlickrSearch
//
//  Created by Himadri Sekhar Jyoti on 17/06/17.
//  Copyright © 2017 Himadri Jyoti. All rights reserved.
//

import Foundation
import CoreData

final class ImageSearchController {
    let flickrSearchUIErrorDomain = "flickrSearchUIError"
    var currentPage: Int = 1
    
    func updateRecentSearchTexts(text: String, inMoc: NSManagedObjectContext) {
        CoreDataHelper.updateNewOrExistingRecentSearchAndWait(moc: inMoc, searhText: text)
    }
    
    func getImageList(searchText: String, itemsPerPage: Int, shouldResetPage: Bool = false, completiononMainThread:@escaping (_ isSuccess: Bool, _ urlList: [ImageUrls]?, _ error: NSError?) -> Void) {
        assert(Thread.isMainThread, "Not main thread")
        
        if shouldResetPage {
            self.currentPage = 1
        }
        
        let request = GetImageListRequestModel(page: self.currentPage, itemsPerPage: itemsPerPage, searchText: searchText)
        FlickrService.getImageList(requestModel: request) {
            response, status in
            
            guard let unwrappedResponse = response, status.result == .success else {
                DispatchQueue.main.async {
                    completiononMainThread(false, nil, status.error)
                }
                return
            }
            
            guard let serverPage = unwrappedResponse.photos?.page,
                serverPage == self.currentPage,
                let photoList = unwrappedResponse.photos?.images,
                photoList.count > 0 else {
                    DispatchQueue.main.async {
                        let error = NSError(domain: self.flickrSearchUIErrorDomain, code: -12000, userInfo:[NSLocalizedFailureReasonErrorKey: NSLocalizedString("url.extraction.failed", comment: "")])
                        completiononMainThread(false, nil, error)
                    }
                    return
            }
            
            var imageList = [ImageUrls]()
            for photo in photoList {
                let original = photo.getOriginalImageUrl()
                let square = photo.getSquareImageUrl()
                let largeSquare = photo.getLargeSquareImageUrl()
                
                imageList.append(ImageUrls(originalUrl: original, squareUrl: square, largeSquareUrl: largeSquare))
            }
            
            
            DispatchQueue.main.async {
                completiononMainThread(true, imageList, nil)
            }
        }
    }
    
}
