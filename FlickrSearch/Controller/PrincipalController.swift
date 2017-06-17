//
//  PrincipalController.swift
//  FlickrSearch
//
//  Created by Himadri Sekhar Jyoti on 17/06/17.
//  Copyright © 2017 Himadri Jyoti. All rights reserved.
//

import Foundation
import BNRCoreDataStack

final class PrincipalController {
    var persistanceController: CoreDataStack!
    var imageSearchController: ImageSearchController!
    
    func initCoreDataStack(completion: @escaping () -> Void) {
        DispatchQueue.main.async {
            CoreDataStack.constructSQLiteStack(modelName: "Model") {
                result in
                switch result {
                case .success(let stack):
                    self.persistanceController = stack
                    DispatchQueue.main.async {
                        completion()
                    }
                    
                case .failure(let error):
                    //Will handle later
                    print("Core data stack creation failed, error=\(error)")
                    abort()
                }
            }
        }
        
    }
    
    
    func initializeSubControllers() {
        self.imageSearchController = ImageSearchController()
    }
    
}
