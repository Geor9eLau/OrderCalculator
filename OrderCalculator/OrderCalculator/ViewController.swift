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
    fileprivate var columnRatio: [CGFloat]!
    fileprivate var defaultTitles: [String]!
    fileprivate var keyboardType: [UIKeyboardType]!
    fileprivate var currentIndexPath: IndexPath?
    
    fileprivate lazy var searchView: GLFormSearchView = {
        let v = GLFormSearchView(frame: CGRect(x: 20, y: GLFormUX.sectionHeaderViewHeight + GLFormUX.rowHeight + Global.navagationBarHeight , width: GLFormUX.searchViewWidth, height:GLFormUX.searchViewHeight) , style: .plain)
        v.gl_delegate = self
        return v
    }()
    
    fileprivate lazy var form: GLForm = {
        let form = GLForm(frame: UIScreen.main.bounds, columnRatio: self.columnRatio, defaultTitles: self.defaultTitles, keyboardType: self.keyboardType)
        form.formDelegate = self
        return form
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "订单记录表"
        columnRatio = [5, 2, 2, 3]
        defaultTitles = ["名称", "单位","数量", "单价"]
        keyboardType = [.default, .default, .decimalPad, .decimalPad]
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
        manager.updateGoodsNameRecord(form.formRecord.recordData)
        if let record = manager.getLastFormRecord(form.formRecord.id) {
            form.updateFormRecord(record)
        }
    }
    
    func gotoNextForm(_ form: GLForm) {
        guard form.formRecord.recordData.count > 0 else {return}
        manager.updateFormRecord(form.formRecord)
        manager.updateGoodsNameRecord(form.formRecord.recordData)
        if let record = manager.getNextFormRecord(form.formRecord.id) {
            form.updateFormRecord(record)
        }
    }
    
    func printForm(_ form: GLForm) {
        manager.updateFormRecord(form.formRecord)
    }
    
    func form(_ form: GLForm, goodsNameDidChange name: String, at indexPath: IndexPath) {
        guard name.characters.count > 0 else {
            return
        }
        currentIndexPath = indexPath
        let nameRecords = manager.getLikelyGoodsName(name)
        if nameRecords.count > 0 {
            searchView.updateResult(nameRecords)
            let yPosition = indexPath.row == 0 ? GLFormUX.sectionHeaderViewHeight + GLFormUX.rowHeight + Global.navagationBarHeight : GLFormUX.sectionHeaderViewHeight + GLFormUX.rowHeight * 2 + Global.navagationBarHeight
            searchView.frame = CGRect(x: GLFormUX.recordIDLabelWidth, y: yPosition, width: GLFormUX.searchViewWidth, height:GLFormUX.searchViewHeight)
            view.addSubview(searchView)
        }else {
            searchView.removeFromSuperview()
        }
    }
    
    

    func form(_ form: GLForm, didFinishGoodsNameEditing name: String, at indexPath: IndexPath) {
        searchView.removeFromSuperview()
        if let s = manager.getRelativeGoodsSpecification(name){
            form.updateGoodsSpecification(s, at: indexPath)
        }
    }
    
    func formDidScroll(_ form: GLForm) {
        searchView.removeFromSuperview()
    }
    
}

// MARK: - GLFormSearchViewDelegate
extension ViewController {
    func tableView(_ tableView: GLFormSearchView, didSelectGoods goods: Goods) {
        searchView.removeFromSuperview()
        if let indexPath = currentIndexPath {
            form.updateGoodsName(goods.name, at: indexPath)
        }
    }
}

