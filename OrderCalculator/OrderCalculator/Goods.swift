//
//  Goods.swift
//  OrderCalculator
//
//  Created by George on 2017/7/20.
//  Copyright © 2017年 George. All rights reserved.
//

import Foundation
import HandyJSON

struct Goods: Equatable, HandyJSON {
    var name: String = ""
    var specification: String = ""
    var amount: Int = 0
    var price: Float = 0
    var frequency: Int!
    var id: String = ""
    
    public static func ==(lhs: Goods, rhs: Goods) -> Bool{
        return lhs.id == rhs.id
    }
    
    static let `default` = Goods(name: "", specification: "", amount: 0, price: 0, frequency: 0, id: "")
    
    subscript(index: Int) -> String {
        switch index{
        case 0: return name
//        case 1: return specification
        case 1: return amount == 0 ? "" : "\(amount)"
        case 2: return price == 0 ? "" : "\(price)"
        default: return ""
        }
    }
    
    mutating func update(type: Int, content: String) {
        switch type {
        case 0: name = content
//        case 1: specification = content
        case 1: amount = Int(content)!
        case 2: price = Float(content)!
        default: break
        }
    }
}
