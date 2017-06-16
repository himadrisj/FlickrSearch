//
//  FlickrService.swift
//  FlickrSearch
//
//  Created by Himadri Sekhar Jyoti on 16/06/17.
//  Copyright © 2017 Himadri Jyoti. All rights reserved.
//

import Foundation

final class FlickrService {
    public static func getImageList(requestModel: GetImageListRequestModel, completionHandler:@escaping (GetImageListResponse?, RequestStatus) -> Void) {
        processRequest(requestModel, apiType: requestModel.apiType()) { $0.getImageListCompletionHandler = completionHandler }
    }
    
    private static func processRequest(_ requestModel: UrlRequestBuilder, apiType: ApiType, setResponseHandlerCallback:((GenericResponseHandler) -> Void)) {
        
        let responseHandler = GenericResponseHandler(apiType: apiType)
        setResponseHandlerCallback(responseHandler)
        
        let requestHelper = RequestHelper(requestBuilder: requestModel, responseHandler: responseHandler)
        RequestManager.sharedInstance.processRequest(requestHelper: requestHelper)
    }
    
}
