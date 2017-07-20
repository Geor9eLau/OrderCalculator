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
    
    
    private override init() {
        super.init()
        let path = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true
            ).first!
        
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
    }
    
    
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
