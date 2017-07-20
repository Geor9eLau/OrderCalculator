//
//  ViewController.swift
//  OrderCalculator
//
//  Created by George on 2017/7/18.
//  Copyright © 2017年 George. All rights reserved.
//

import UIKit

class ViewController: UIViewController, GLFormDelegate {

    
    fileprivate let manager = GLDataManager.sharedInstance
    override func viewDidLoad() {
        super.viewDidLoad()
        let form = GLForm(frame: UIScreen.main.bounds, columnRatio: [3, 3, 3, 3])
        form.formDelegate = self
        view.addSubview(form)
        
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


// MARK: - GLFormDelegate
extension ViewController {
    func gotoPreviousForm(_ form: GLForm) {
        manager.updateFormRecord(form.formRecord)
        if let record = manager.getLastFormRecord(form.formRecord.id) {
            form.updateRecord(record)
        }
    }
    
    func gotoNextForm(_ form: GLForm) {
        guard form.formRecord.recordData.count > 0 else {return}
        manager.updateFormRecord(form.formRecord)
        if let record = manager.getNextFormRecord(form.formRecord.id) {
            form.updateRecord(record)
        }
    }
    
    func printForm(_ form: GLForm) {
        manager.updateFormRecord(form.formRecord)
    }
}

