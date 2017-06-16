//
//  GenericResponseHandler.swift
//  FlickrSearch
//
//  Created by Himadri Sekhar Jyoti on 16/06/17.
//  Copyright © 2017 Himadri Jyoti. All rights reserved.
//

import Foundation
import ObjectMapper

final class GenericResponseHandler: ResponseHandler  {
    let apiType: ApiType
    
    var getImageListCompletionHandler: ((GetImageListResponse?, RequestStatus) -> Void)?
    
    init(apiType: ApiType) {
        self.apiType = apiType
    }
    
    func handleResponse(data: Data?, requestStatus: RequestStatus) {
        
        switch apiType {
        case .getImageList:
            if let completion = self.getImageListCompletionHandler {
                self.parseGeneric(data: data,  requestStatus: requestStatus, type: GetImageListResponse.self, completionHandler: completion)
            }
            else {
                assert(false, "No completion handler")
            }
            
        }
        
    }
    
    
    func parseGeneric<T: Mappable>(data: Data?, requestStatus: RequestStatus, type: T.Type, completionHandler:(T?, RequestStatus) -> Void) {
        var serverResponse: String?
        if let serverData = data, let stringFromData = String(data:serverData, encoding: String.Encoding.utf8) {
            serverResponse = stringFromData
        }
        
        if(requestStatus.result == .success) {
            if let unwrappedServerResponse = serverResponse, let parsedResponse = Mapper<T>().map(JSONString: unwrappedServerResponse) {
                //Parsing sucessful
                completionHandler(parsedResponse, requestStatus)
            }
            else {
                //Parsing failed
                completionHandler(nil, self.requestStatusForJSONParsingFailed(httpStatusCode: requestStatus.httpStatusCode, serverErrorResponse: serverResponse))
            }
        }
        else {
            completionHandler(nil, requestStatus)
        }
    }
    
    
    func requestStatusForJSONParsingFailed(httpStatusCode: Int?, serverErrorResponse: String?) -> RequestStatus {
        let errorDomain = NetworkConstants.errorDomain
        let errorCode: NetworkErrorCode = .jsonParsingFailed
        let error = NSError(domain: errorDomain, code: errorCode.rawValue, userInfo:[NSLocalizedFailureReasonErrorKey:errorCode.errorString()])
        return RequestStatus(result: .failure, httpStatusCode: httpStatusCode, error: error, serverErrorResponse: serverErrorResponse)
    }
}
