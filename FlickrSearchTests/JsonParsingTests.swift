//
//  JsonParsingTests.swift
//  FlickrSearch
//
//  Created by Himadri Sekhar Jyoti on 16/06/17.
//  Copyright © 2017 Himadri Jyoti. All rights reserved.
//

import XCTest
import ObjectMapper
@testable import FlickrSearch

class JsonParsingTests: XCTestCase {
    
    enum JsonParsingTestError: Error {
        case unwrappingFailed
        case stringConversionFailed
    }
    
    var searchResponse: String!
    var parsedResponse: GetImageListResponse!
    
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let path =  Bundle(for: type(of: self)).path(forResource: "ImageSearchResult", ofType: "json")
        if let path = path {
            searchResponse = try? NSString(contentsOfFile: path, encoding: String.Encoding.utf8.rawValue) as String
        }
        
        let photoDetail = PhotoDetails(id: "35133224252", owner: "155837775@N05", secret: "d84cea1eaa", server: "4199", farm: 5, title: "Monkey forest, Bali.")
        let pageDetails = PageDetails(page: 1, pages: 213259, perPage: 1, total: "213259", images: [photoDetail])
        parsedResponse = GetImageListResponse(photos: pageDetails, stat: "ok")
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        searchResponse = nil
        parsedResponse = nil
        super.tearDown()
    }
    
    func testFromJson() throws {
        guard let stringResponse = searchResponse, let objResponse = parsedResponse else {
            throw JsonParsingTestError.unwrappingFailed
        }
        
        let localObjResponse = Mapper<GetImageListResponse>().map(JSONString: stringResponse)
        XCTAssert(localObjResponse == objResponse)
    }
    
    
    func testToJson() throws {
        guard let objResponse = parsedResponse else {
            throw JsonParsingTestError.unwrappingFailed
        }
        
        guard let json = objResponse.toJSONString() else {
            throw JsonParsingTestError.stringConversionFailed
        }
        
        let newObj = Mapper<GetImageListResponse>().map(JSONString: json)
        XCTAssert(objResponse == newObj)
    }
    
    
}
