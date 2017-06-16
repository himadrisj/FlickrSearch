//
//  NetworkTests.swift
//  FlickrSearch
//
//  Created by Himadri Sekhar Jyoti on 17/06/17.
//  Copyright © 2017 Himadri Jyoti. All rights reserved.
//

import XCTest
@testable import FlickrSearch

class NetworkTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testApiCallBack() {
        let expectation = XCTestExpectation(description: "Get Images API Callback")
        var start = "Start"
        let requestModel = GetImageListRequestModel(page: 1, itemsPerPage: 30, searchText: "Monkey")
        FlickrService.getImageList(requestModel: requestModel) {
            response, status in
            expectation.fulfill()
            start += "End"
            XCTAssert(start == "StartEnd")
        }
        
        self.wait(for: [expectation], timeout: 3)
    }
}
