//
//  RequestManager.swift
//  FlickrSearch
//
//  Created by Himadri Sekhar Jyoti on 16/06/17.
//  Copyright © 2017 Himadri Jyoti. All rights reserved.
//

import Foundation

final class RequestHelper {
    let requestBuilder: UrlRequestBuilder
    let responseHandler: ResponseHandler
    
    init(requestBuilder: UrlRequestBuilder, responseHandler: ResponseHandler) {
        self.requestBuilder = requestBuilder
        self.responseHandler = responseHandler
    }
}

final class RequestManager {
    static let sharedInstance: RequestManager = {
        let manager = RequestManager()
        return manager
    }()
    
    let session: URLSession
    
    init() {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.timeoutIntervalForRequest = NetworkConstants.requestTimeout
        configuration.httpMaximumConnectionsPerHost = NetworkConstants.maxConcurrentConnection
        configuration.httpShouldUsePipelining = true
        
        session = URLSession(configuration: configuration)
    }
    
    func processRequest(requestHelper: RequestHelper) {
        let dataTask = self.session.dataTask(with: requestHelper.requestBuilder.urlRequest()) {
            data, response, error in
            
            let requestStatus = self.getRequestStatusForTask(data: data, response: response, error: error as NSError?)
            requestHelper.responseHandler.handleResponse(data: data, requestStatus: requestStatus)
        }
        
        dataTask.resume()
    }
    
    
    private func getRequestStatusForTask(data: Data?, response: URLResponse?, error: NSError?) -> RequestStatus {
        var serverResponse: String?
        if let serverData = data, let stringFromData = String(data:serverData, encoding: String.Encoding.utf8) {
            serverResponse = stringFromData
        }
        
        if let error = error {
            // URLSession error
            return RequestStatus(result: .failure, httpStatusCode: nil, error: error, serverErrorResponse: serverResponse)
        }
        else if let httpResponse = response as? HTTPURLResponse {
            let successStatusCode: CountableRange<Int> = 200..<300
            if (successStatusCode.contains(httpResponse.statusCode)) {
                //Server sucess
                return RequestStatus(result: .success, httpStatusCode: httpResponse.statusCode, error: nil, serverErrorResponse: nil)
            }
            else {
                //Server error
                return RequestStatus(result: .failure, httpStatusCode: httpResponse.statusCode, error: nil, serverErrorResponse: serverResponse)
            }
        }
        
        assert(false, "Something wrong")
        return RequestStatus(result:  .failure, httpStatusCode: nil, error: nil, serverErrorResponse: serverResponse)
    }
}
