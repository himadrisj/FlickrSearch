//
//  NetworkConstants.swift
//  FlickrSearch
//
//  Created by Himadri Sekhar Jyoti on 16/06/17.
//  Copyright © 2017 Himadri Jyoti. All rights reserved.
//

import Foundation

enum NetworkErrorCode: Int {
    case jsonParsingFailed = -14000
    
    func errorString() -> String {
        switch self {
        case .jsonParsingFailed:
            return NSLocalizedString("network.json.parsing.failed", comment: "JSON parsing failed")
        }
    }
}



struct NetworkConstants {
    static let flickrBaseUrl = "https://api.flickr.com/services/rest/"
    static let apiKey = "3e7cc266ae2b0e0d78e279ce8e361736"
    
    static let apiResponseFormat = "json"
    
    static let errorDomain = "flickrSearch"
    
    static let requestTimeout = 60.0
    static let maxConcurrentConnection = 3
    
}
