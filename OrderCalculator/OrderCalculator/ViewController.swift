//
//  ViewController.swift
//  OrderCalculator
//
//  Created by George on 2017/7/18.
//  Copyright © 2017年 George. All rights reserved.
//

import UIKit

class ViewController: UIViewController, GLFormDelegate, GLFormSearchViewDelegate {

    fileprivate let manager = GLDataManager.sharedInstance
    
    fileprivate lazy var searchView: GLFormSearchView = {
        let v = GLFormSearchView(frame: CGRect(x: 20, y: GLFormUX.sectionHeaderViewHeight + GLFormUX.rowHeight + Global.navagationBarHeight , width: GLFormUX.searchViewWidth, height:GLFormUX.searchViewHeight) , style: .plain)
        v.gl_delegate = self
        return v
    }()
    
    fileprivate lazy var form: GLForm = {
        let form = GLForm(frame: UIScreen.main.bounds, columnRatio: [5, 2, 2, 3], defaultTitles: ["名称", "规格", "数量", "价格"])
        form.formDelegate = self
        return form
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "订单记录表"
        view.addSubview(form)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        
        
        print("!!!!!")
    }
}



// MARK: - GLFormDelegate
extension ViewController {
    func gotoPreviousForm(_ form: GLForm) {
        manager.updateFormRecord(form.formRecord)
        if let record = manager.getLastFormRecord(form.formRecord.id) {
            form.updateFormRecord(record)
        }
    }
    
    func gotoNextForm(_ form: GLForm) {
        guard form.formRecord.recordData.count > 0 else {return}
        manager.updateFormRecord(form.formRecord)
        if let record = manager.getNextFormRecord(form.formRecord.id) {
            form.updateFormRecord(record)
        }
    }
    
    func printForm(_ form: GLForm) {
        manager.updateFormRecord(form.formRecord)
    }
    
    func form(_ form: GLForm, goodsNameDidChange name: String) {
        if let nameRecords = manager.getLikelyGoodsName(name),
            nameRecords.count > 0 {
            view.addSubview(searchView)
            searchView.updateResult(nameRecords)
        }else {
            searchView.removeFromSuperview()
        }
    }
    
    
    func form(_ form: GLForm, didFinishGoodsNameEditing name: String) {
        manager.updateGoodsNameRecord(name)
        searchView.removeFromSuperview()
    }
    
    func formDidScroll(_ form: GLForm) {
        searchView.removeFromSuperview()
    }
}

// MARK: - GLFormSearchViewDelegate
extension ViewController {
    func tableView(_ tableView: GLFormSearchView, didSelectGoodsRecord record: GoodsNameRecord, at indexPath: IndexPath) {
        searchView.removeFromSuperview()
        form.updateGoodsName(record.name, at: indexPath)
    }
}

