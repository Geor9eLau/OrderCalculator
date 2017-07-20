//
//  Extension.swift
//  OrderCalculator
//
//  Created by George on 2017/7/19.
//  Copyright © 2017年 George. All rights reserved.
//

import Foundation
extension Array where Element == Goods{
    
    /// 更新指定商品的数据
    ///
    /// - Parameter newGoodsRecord: 指定的商品
    mutating func update(_ newGoodsRecord: Goods) {
            let index = self.index(of: newGoodsRecord)
            self[index!] = newGoodsRecord
    }
    
    
    /// 计算商品总额
    ///
    /// - Returns: 总额
    func total() -> Float {
        return self.reduce(0, {$0 + $1.price * Float($1.amount)})
    }
}
