//
//  StrictMappable.swift
//  FlickrSearch
//
//  Created by Himadri Sekhar Jyoti on 16/06/17.
//  Copyright © 2017 Himadri Jyoti. All rights reserved.
//

import Foundation
import ObjectMapper

//Creating a "strict" mappable protocol which won't proceed with JSON parsing if "mandatory" keys are not present
protocol StrictMappable: Mappable {
    var mandatoryKeys: [String] { get }
    
    func mandatoryKeysExists(_ map: Map) -> Bool
}


extension StrictMappable  {
    func mandatoryKeysExists(_ map: Map) -> Bool {
        var allKeysExists = true
        
        let keysPresent = map.JSON.keys
        for key in self.mandatoryKeys {
            if(!keysPresent.contains(key)) {
                allKeysExists = false
                break
            }
        }
        
        return allKeysExists
    }
}
