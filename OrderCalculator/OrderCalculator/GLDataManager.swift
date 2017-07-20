//
//  GLDataManager.swift
//  OrderCalculator
//
//  Created by George on 2017/7/20.
//  Copyright © 2017年 George. All rights reserved.
//

import Foundation
class GLDataManager: NSObject {
    static let sharedInstance: GLDataManager = {
       return GLDataManager()
    }()
    
    private override init() {}
}
