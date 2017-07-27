//
//  GLDataManager.swift
//  OrderCalculator
//
//  Created by George on 2017/7/20.
//  Copyright © 2017年 George. All rights reserved.
//

import Foundation
import SQLite
import HandyJSON

class GLDataManager: NSObject {
    static let sharedInstance: GLDataManager = {
        return GLDataManager()
    }()
    
    fileprivate var database: Connection?
    fileprivate let formRecordTable = Table("FormRecord")
    fileprivate let formId = Expression<Int>("id")
    fileprivate let recordData = Expression<Blob>("recordData")
    
    fileprivate let goodsTable = Table("Goods")
    fileprivate let goodsName = Expression<String>("name")
    fileprivate let specification = Expression<String>("specification")
    fileprivate let frequency = Expression<Int>("frequency")
    fileprivate let price = Expression<Double>("price")
    
    private override init() {
        super.init()
        let path = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true
            ).first!
        print(path)
        do {
            database = try Connection("\(path)/db.sqlite3")
        } catch let error {
            print(error)
        }
        
        
        do {
            try database!.run(formRecordTable.create(ifNotExists: true, block: { (t) in
                t.column(formId, primaryKey: true)
                t.column(recordData)
            }))
        } catch let error {
            print(error)
        }
        
        do {
            try database!.run(goodsTable.create(ifNotExists: true, block: { (t) in
                t.column(goodsName, primaryKey: true)
                t.column(specification)
                t.column(frequency)
                t.column(price)
            }))
        } catch let error {
            print(error)
        }
    }
    
    
    
}

// MARK: - 订单相关
extension GLDataManager{
    func updateFormRecord(_ formRecord: FormRecord) {
        if let jsonStr = formRecord.recordData.toJSONString(),
            let data = jsonStr.data(using: .utf8) {
            do{
                try database?.run(formRecordTable.insert(or: .replace, formId <- formRecord.id,
                                                         recordData <- data.datatypeValue))
            }
            catch let error {
                print(error)
            }
        }
    }
    
    func getCurrentFormRecordId() -> Int {
        do {
            if let maxId = try database?.prepare(formRecordTable.order(formId.desc).select(formId).limit(1)).first(where: {return $0.get(formId) > 0})?.get(formId){
                return maxId + 1
            }else{
                return 0
            }
        }
        catch let error {
            print(error)
        }
        return 0
    }
    
    func getLastFormRecord(_ currentFormId: Int) -> FormRecord? {
        guard currentFormId > 0 else {return nil}
        
        do {
            if let record = try database?.prepare(formRecordTable.filter(formId == currentFormId - 1)).first(where: {_ in return true}),
                let jsonStr = String(data: Data(bytes: record.get(recordData).bytes), encoding: .utf8),
                let formRecordata = [Goods].deserialize(from: jsonStr)
            {
                let formRecordId = record.get(formId)
                return FormRecord(id: formRecordId, recordData: formRecordata as! [Goods])
                
            }else{
                return nil
            }
        }
        catch let error {
            print(error)
        }
        return nil
    }
    
    func getNextFormRecord(_ currentFormId: Int) -> FormRecord? {
        
        do {
            if let record = try database?.prepare(formRecordTable.filter(formId == currentFormId + 1)).first(where: {_ in return true}),
                let jsonStr = String(data: Data(bytes: record.get(recordData).bytes), encoding: .utf8),
                let formRecordata = [Goods].deserialize(from: jsonStr)
            {
                let formRecordId = record.get(formId)
                return FormRecord(id: formRecordId, recordData: formRecordata as! [Goods])
                
            }else{
                return FormRecord(id: currentFormId + 1, recordData: [])
            }
        }
        catch let error {
            print(error)
        }
        return nil
    }
}

// MARK: - 商品相关
extension GLDataManager{
    func updateGoodsNameRecord(_ allGoods: [Goods]) {
        
        for goods in allGoods {
            do {
                if let result = try database?.prepare(goodsTable.filter(goodsName == goods.name)).first(where: {$0.get(goodsName) == goods.name}){
                    let n = result.get(goodsName)
                    let f = result.get(frequency) + 1
                    var s: String
                    if goods.specification.characters.count > 0 {
                        s = goods.specification
                    } else {
                        s = result.get(specification)
                    }
                    insertOrReplaceGoodsNameRecord(Goods(name: n, specification: s, amount: 0, price: Float(result.get(price)), frequency: f, id: ""))
                } else {
                    insertOrReplaceGoodsNameRecord(goods)
                }
            }
            catch let error {
                print(error)
            }
        }
    }
    
     fileprivate func insertOrReplaceGoodsNameRecord(_ goods: Goods) {
        do{
            try database?.run(goodsTable.insert(or: .replace, goodsName <- goods.name,
                                                     frequency <- goods.frequency,
                                                     specification <- goods.specification,
                                                     price <- Double(goods.price)))
        }
        catch let error {
            print(error)
        }
    }
    
    func getLikelyGoodsName(_ keyword: String) -> [Goods] {
        do{
            if let result = try database?.prepare(goodsTable.select(goodsName).filter(goodsName.like("%\(keyword)_%")).order(frequency.desc).limit(5)){
                var goodsArr: [Goods] = []
                for name in result {
                    var tmpGoods = Goods.default
                    let n = name.get(goodsName)
                    tmpGoods.name = n
                    goodsArr.append(tmpGoods)
                }
                return goodsArr
            }
            return []
        }
        catch let error {
            print(error)
        }
        return []
    }
    
    func getRelativeGoodsSpecification(_ name: String) -> String? {
        do{
            if let result = try database?.prepare(goodsTable.select(specification).filter(goodsName == name).order(frequency.desc).limit(5)).first(where: {_ in return true}),
                result.get(specification).characters.count > 0 {
                let s = result.get(specification)
                return s
            }
            return nil
        }
        catch let error {
            print(error)
        }
        return nil
    }
}

