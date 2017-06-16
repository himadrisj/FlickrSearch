//
//  NetworkLayerProtocols.swift
//  FlickrSearch
//
//  Created by Himadri Sekhar Jyoti on 16/06/17.
//  Copyright © 2017 Himadri Jyoti. All rights reserved.
//

import Foundation


enum ApiType: Int {
    case getImageList
}

//MARK: Request Protocols
protocol BaseUrlDataProvider {
    func apiBaseUrl() -> String
    
    func apiMethodName() -> String
    
    func apiKey() -> String
    
    func httpMethod() -> String
    
    func apiType() -> ApiType
}

//Common Implementation
extension BaseUrlDataProvider {
    func apiBaseUrl() -> String {
        return NetworkConstants.flickrBaseUrl
    }
    
    func apiKey() -> String {
        return NetworkConstants.apiKey
    }
}


protocol RequestMetaDataProvider: BaseUrlDataProvider {
    func addHeaders(_ urlRequest: NSMutableURLRequest)
    
    func addBody(_ urlRequest: NSMutableURLRequest)
    
    func commonQueryitems() -> [String: String]
    
    func queryItems() -> [String: String]
    
    func apiUrlPath() -> String
}


//Common Implementation
extension RequestMetaDataProvider {
    func addHeaders(_ urlRequest: NSMutableURLRequest) {
        //Default implementation doesn't add any headers
    }
    
    func addBody(_ urlRequest: NSMutableURLRequest) {
        //Default implementation doesn't add any body data
    }
    
    func queryItems() -> [String: String] {
        //Default implementation
        return [String: String]()
    }
    
    func commonQueryitems() -> [String: String] {
        var queryParams = [String: String]()
        
        queryParams["method"] = apiMethodName()
        queryParams["api_key"] = apiKey()
        queryParams["format"] = NetworkConstants.apiResponseFormat
        queryParams["nojsoncallback"] = "1"
        
        return queryParams
    }
    
    func apiUrlPath() -> String {
        //Default implementation returns base url, any path parameter substitution has to be done in overriden implementation
        return apiBaseUrl()
    }
}


protocol UrlRequestBuilder: RequestMetaDataProvider {
    func urlRequest() -> URLRequest
}


//Common Implementation
extension UrlRequestBuilder {
    func urlRequest() -> URLRequest {
        let request = NSMutableURLRequest()
        
        
        addHeaders(request)
        addBody(request)
        request.httpMethod = httpMethod()
        
        
        let urlPath = apiUrlPath()
        request.url = URL(string: urlPath)
        
        //Set query items if any
        var queryParams = [String: String]()
        let commonQueryItems = commonQueryitems()
        for (key, value) in commonQueryItems {
            queryParams[key] = value
        }
        
        let specialQueryItems = queryItems()
        for (key, value) in specialQueryItems {
            queryParams[key] = value
        }
        
        if !queryParams.isEmpty {
            setQueryItems(queryDict: queryParams, urlPath: urlPath, urlRequest: request)
        }
        
        return request as URLRequest
    }
    
    
    func setQueryItems(queryDict:[String: String], urlPath: String, urlRequest: NSMutableURLRequest) {
        if var urlComponents = URLComponents(string: urlPath) {
            var queryItems = [URLQueryItem]()
            
            for (paramKey, paramValue) in queryDict {
                let queryItem = URLQueryItem(name: paramKey, value: paramValue)
                queryItems.append(queryItem)
            }
            
            urlComponents.queryItems = queryItems
            urlRequest.url = urlComponents.url
        }
        else {
            assert(false, "Can't form URL components")
        }
    }
    
}








//MARK: Response Protocols
enum RequestResult: String {
    case success
    case failure
}

struct RequestStatus {
    let result: RequestResult
    let httpStatusCode: Int?
    let error: NSError?
    let serverErrorResponse: String?
}


protocol ResponseHandler {
    func handleResponse(data: Data?, requestStatus: RequestStatus)
}
