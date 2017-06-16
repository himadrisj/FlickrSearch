//
//  GetImageListRequestModels.swift
//  FlickrSearch
//
//  Created by Himadri Sekhar Jyoti on 16/06/17.
//  Copyright © 2017 Himadri Jyoti. All rights reserved.
//

import Foundation
import ObjectMapper


//MARK: Request
struct GetImageListRequestModel {
    let page: Int
    let itemsPerPage: Int
    let searchText: String
}

extension GetImageListRequestModel: UrlRequestBuilder {
    func apiMethodName() -> String {
        return "flickr.photos.search"
    }
    
    
    func httpMethod() -> String {
        return "GET"
    }
    
    func apiType() -> ApiType {
        return .getImageList
    }
    
    func queryItems() -> [String: String] {
        var queryParamDict = [String: String]()
        
        queryParamDict["page"] = String(self.page)
        queryParamDict["per_page"] = String(self.itemsPerPage)
        queryParamDict["text"] = self.searchText
        
        //Implicitly set query items
        queryParamDict["safe_search"] = "1"
        
        
        return queryParamDict
    }
}

//MARK: Response
struct PhotoDetails {
    var id: String?
    var owner: String?
    var secret: String?
    var server: String?
    var farm: Int?
    var title: String?
}

extension PhotoDetails: StrictMappable {
    var mandatoryKeys: [String] { return ["id", "secret", "server", "farm"] }
    
    init?(map: Map) {
        if(!mandatoryKeysExists(map)) {
            assert(false, "Mandatory keys doesn't exist")
            return nil
        }
    }
    
    mutating func mapping(map: Map) {
        id <- map["id"]
        owner <- map["owner"]
        secret <- map["secret"]
        server <- map["server"]
        farm <- map["farm"]
        title <- map["title"]
    }
}

//For testing
extension PhotoDetails: Equatable {
    static func ==(lhs: PhotoDetails, rhs: PhotoDetails) -> Bool {
        return
            lhs.id == rhs.id &&
                lhs.owner == rhs.owner &&
                lhs.secret == rhs.secret &&
                lhs.server == rhs.server &&
                lhs.farm == rhs.farm &&
                lhs.title == rhs.title
    }
}

//Image URL extraction
extension PhotoDetails {
    func getOriginalImageUrl() -> String? {
        guard let id = self.id,
            let secret = self.secret,
            let server = self.server,
            let farm = self.farm else {
                assert(false, "Mandatory keys doesn't exist")
                return nil
        }
        
        return String(format: "https://farm%d.static.flickr.com/%@/%@_%@.jpg", farm, server, id, secret)
    }
    
    //75 x 75
    func getSquareImageUrl() -> String? {
        guard let id = self.id,
            let secret = self.secret,
            let server = self.server,
            let farm = self.farm else {
                assert(false, "Mandatory keys doesn't exist")
                return nil
        }
        
        return String(format: "https://farm%d.static.flickr.com/%@/%@_%@_s.jpg", farm, server, id, secret)
    }
    
    //150 x 150
    func getLargeSquareImageUrl() -> String? {
        guard let id = self.id,
            let secret = self.secret,
            let server = self.server,
            let farm = self.farm else {
                assert(false, "Mandatory keys doesn't exist")
                return nil
        }
        
        return String(format: "https://farm%d.static.flickr.com/%@/%@_%@_q.jpg", farm, server, id, secret)
    }
    
}


struct PageDetails {
    var page: Int?
    var pages: Int?
    var perPage: Int?
    var total: String?
    var images: [PhotoDetails] =  [PhotoDetails]()
}

extension PageDetails: Mappable {
    init?(map: Map) { }
    
    mutating func mapping(map: Map) {
        page <- map["page"]
        pages <- map["pages"]
        perPage <- map["perpage"]
        total <- map["total"]
        images <- map["photo"]
    }
}

//For testing
extension PageDetails: Equatable {
    static func ==(lhs: PageDetails, rhs: PageDetails) -> Bool {
        return
            lhs.page == rhs.page &&
                lhs.pages == rhs.pages &&
                lhs.perPage == rhs.perPage &&
                lhs.total == rhs.total &&
                lhs.images == rhs.images
    }
}



struct GetImageListResponse {
    var photos: PageDetails?
    var stat: String?
}

extension GetImageListResponse: Mappable {
    init?(map: Map) { }
    
    mutating func mapping(map: Map) {
        photos <- map["photos"]
        stat <- map["stat"]
    }
}


//For testing
extension GetImageListResponse: Equatable {
    static func ==(lhs: GetImageListResponse, rhs: GetImageListResponse) -> Bool {
        return
            lhs.photos == rhs.photos &&
                lhs.stat == rhs.stat
    }
}

