//
//  GLForm.swift
//  OrderCalculator
//
//  Created by George on 2017/7/18.
//  Copyright © 2017年 George. All rights reserved.
//

import UIKit




protocol GLFormCellDelegate: class {
    func recordDone(_ indexPath: IndexPath, _ goodsRecord: Goods)
    func goodsNameStringDidChange(_ name: String)
}

class GLFormCell: UITableViewCell, GLTextFieldDelegate {
    let columnTextFiledOriginTag = 8888
    fileprivate var columnRatio: [CGFloat] = []
    var hasLoaded: Bool = false
    weak var delegate: GLFormCellDelegate?
    var indexPath: IndexPath!
    var isHeader: Bool = false
    fileprivate var goodsRecord = Goods.default
    fileprivate var goodsRecordId: String {
        return "\(indexPath.row)"
    }
    

    override func draw(_ rect: CGRect) {
        UIColor.black.setStroke()
        
        let bottomLine = UIBezierPath()
        bottomLine.move(to: CGPoint(x: 0, y: rect.height))
        bottomLine.addLine(to: CGPoint(x: rect.width, y: rect.height))
        bottomLine.lineWidth = 1
        bottomLine.stroke()
        
        let leftLine = UIBezierPath()
        leftLine.move(to: CGPoint(x: 0, y: 0))
        leftLine.addLine(to: CGPoint(x: 0, y: rect.height))
        leftLine.lineWidth = 1
        leftLine.stroke()
        
        let rightLine = UIBezierPath()
        rightLine.move(to: CGPoint(x: rect.width, y: 0))
        rightLine.addLine(to: CGPoint(x: rect.width, y: rect.height))
        rightLine.lineWidth = 1
        rightLine.stroke()
        
    }
    
    /// 绘制表格（及填充商品信息）
    ///
    /// - Parameters:
    ///   - columnRatio: 每一栏的比例
    ///   - goodsRecord: 商品数据
    ///   - customFrame: 自定义的frame
    func loadContentView(with columnRatio: [CGFloat], customFrame: CGRect? = nil, keyboardType: [UIKeyboardType]? = nil){
        assert(columnRatio.reduce(0, {$0 + $1}) == 12, "The sum of the columnRatio is required to equal to 12")
        if keyboardType != nil {
            assert(keyboardType!.count == columnRatio.count, "The count of the 'keyboardType'Array is required to equal to 'columnRatio'Array's ")
        }
        selectionStyle = .none
        self.columnRatio = columnRatio
        var height: CGFloat
        var width: CGFloat
        if customFrame == nil {
            width = frame.width
            height = frame.height
        } else {
            width = customFrame!.width
            height = customFrame!.height
        }
        
        var tmpTfOriginX:CGFloat = 0
        for (index, ratio) in columnRatio.enumerated() {
            let tmpTf = GLTextField(frame: CGRect(x: tmpTfOriginX, y: 0, width: width * (ratio / 12.0), height: height))
            tmpTf.gl_delegate = self
            tmpTf.borderStyle = .none
            tmpTf.textAlignment = .center
            tmpTf.font = UIFont.systemFont(ofSize: 15)
            tmpTf.tag = columnTextFiledOriginTag + index
            tmpTf.isUserInteractionEnabled = !isHeader
            tmpTf.keyboardType = keyboardType == nil ? .default : keyboardType![index]
            #if true
                if index == 0 {
                    tmpTf.addTarget(self, action: #selector(textFiledValueChange(_:)), for: .valueChanged)
                }
            #endif
            
            addSubview(tmpTf)
            
            tmpTfOriginX += width * (ratio / 12.0)
            if index < columnRatio.count - 1 {
                let dividedLine = UIView(frame: CGRect(x: tmpTfOriginX, y: 0, width: 1, height: height))
                dividedLine.backgroundColor = UIColor.black
                addSubview(dividedLine)
            }
        }
        hasLoaded = true
    }
    
    
    /// 加载商品数据
    ///
    /// - Parameter goodsRecord: 商品数据
    func loadRecord(_ goodsRecord: Goods = Goods.default) {
        self.goodsRecord = goodsRecord
        for index in 0...3 {
            if let tmpTf = viewWithTag(columnTextFiledOriginTag + index) as? UITextField {
                tmpTf.text = goodsRecord[index]
            }
        }
        
        
    }
    
    
    func setDefaultTitle(_ titles:[String]) {
        for index in 0...columnRatio.count - 1 {
            if let tf = viewWithTag(index + columnTextFiledOriginTag) as? UITextField {
                tf.text = titles[index]
            }
        }
    }
    
    /// 将当前行的第一个输入框设为第一响应者
    func turnToBeFirstResponder() {
        if hasLoaded {
            if let tf = viewWithTag(columnTextFiledOriginTag) as? UITextField {
                tf.becomeFirstResponder()
            }
        }
    }
    
    
    @objc private func textFiledValueChange(_ textField: UITextField){
        if let validDelegate = delegate {
            validDelegate.goodsNameStringDidChange(textField.text!)
        }
    }
}


// MARK: - GLTextFieldDelegate
extension GLFormCell {
    internal func textFieldDidTapNextButton(_ textField: GLTextField) {
        if textField.tag - columnTextFiledOriginTag == 0
            && textField.text?.characters.count == 0 {
            GLAlertView.show("商品名称不能为空!")
            return
        }
        
        if textField.tag + 1 - columnTextFiledOriginTag < columnRatio.count,
            let tf = viewWithTag(textField.tag + 1) as? GLTextField{
            if (textField.text?.characters.count)! > 0 {
                goodsRecord.update(type: textField.tag - columnTextFiledOriginTag, content: textField.text!)
            }
            tf.becomeFirstResponder()
        }
    }
    
    internal func textFieldDidTapPreviousButton(_ textField: GLTextField) {
        if textField.tag - 1 - columnTextFiledOriginTag >= 0 ,
            let tf = viewWithTag(textField.tag - 1) as? GLTextField{
            tf.becomeFirstResponder()
            
        }
    }
    
    internal func textFieldDidTapFinishButton(_ textField: GLTextField) {
        if (textField.text?.characters.count)! > 0 {
            goodsRecord.update(type: textField.tag - columnTextFiledOriginTag, content: textField.text!)
            goodsRecord.id = goodsRecordId
            if textField.tag + 1 - columnTextFiledOriginTag < columnRatio.count,
                let tf = viewWithTag(textField.tag + 1) as? GLTextField{
                tf.becomeFirstResponder()
            }else {
                if let validDelegate = delegate {
                    validDelegate.recordDone(indexPath, goodsRecord)
                }
            }
        } else {
            textField.resignFirstResponder()
        }
    }
    
    internal func textFieldShouldTapReturn(_ textField: GLTextField) -> Bool {
        if (textField.text?.characters.count)! > 0 {
            goodsRecord.update(type: textField.tag - columnTextFiledOriginTag, content: textField.text!)
            goodsRecord.id = goodsRecordId
            if textField.tag + 1 - columnTextFiledOriginTag < columnRatio.count,
                let tf = viewWithTag(textField.tag + 1) as? GLTextField{
                tf.becomeFirstResponder()
            }
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
    
    internal func textFieldShouldStartEditing(_ textField: GLTextField) -> Bool {
        if textField.tag - columnTextFiledOriginTag == 0{
            return true
        } else {
            if goodsRecord.name.characters.count > 0 {
                return true
            } else {
                GLAlertView.show("请先输入商品名称!")
                return false
            }
        }
    }
}

protocol GLFormHeaderDelegate: class{
    func previousButtonDidTapped(_ header: GLFormHeader)
    func nextButtonDidTapped(_ header: GLFormHeader)
    func printButtonDidTapped(_ header: GLFormHeader)
}

class GLFormHeader: UIView {
    weak var delegate: GLFormHeaderDelegate?
    private lazy var totalLabel: UILabel = {
        let totalLabel = UILabel(frame: CGRect(x: self.frame.width / 2 + self.frame.width / 4 - 20, y: 0, width: (self.frame.width / 4), height: self.frame.height))
        totalLabel.text = "金额:"
        totalLabel.textColor = UIColor.black
        totalLabel.textAlignment = .left
        return totalLabel
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layer.borderColor = UIColor.black.cgColor
        layer.borderWidth = 1
        
        let previousBtn = UIButton(frame: CGRect(x: 20, y: 0, width: (frame.width / 4 - 30), height: frame.height))
        previousBtn.setTitle("<", for: .normal)
        previousBtn.setTitleColor(UIColor.black, for: .normal)
        previousBtn.addTarget(self, action: #selector(previousBtnDidClicked), for: .touchUpInside)
        
        let nextBtn = UIButton(frame: CGRect(x: 20 + (frame.width / 4 - 30) + 20, y: 0, width: (frame.width / 4 - 20), height: frame.height))
        nextBtn.setTitle(">", for: .normal)
        nextBtn.setTitleColor(UIColor.black, for: .normal)
        nextBtn.addTarget(self, action: #selector(nextBtnDidClicked), for: .touchUpInside)
        
        let printBtn = UIButton(frame: CGRect(x: frame.width / 2, y: 0, width: (frame.width / 4 - 30), height: frame.height))
        printBtn.setTitle("打印", for: .normal)
        printBtn.setTitleColor(UIColor.black, for: .normal)
        printBtn.addTarget(self, action: #selector(printBtnDidClicked), for: .touchUpInside)
    
        
        addSubview(previousBtn)
        addSubview(nextBtn)
        addSubview(printBtn)
        addSubview(totalLabel)
    }
    
    func updateTotal(_ total: Float){
        totalLabel.text = "金额:\(total)"
    }
    
    @objc private func previousBtnDidClicked() {
        if delegate != nil {
            delegate!.previousButtonDidTapped(self)
        }
    }
    
    @objc private func nextBtnDidClicked() {
        if delegate != nil {
            delegate!.nextButtonDidTapped(self)
        }
    }
    
    @objc private func printBtnDidClicked() {
        if delegate != nil {
            delegate!.printButtonDidTapped(self)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}




// MARK: -
protocol GLFormDelegate: class {
    func gotoNextForm(_ form: GLForm)
    func gotoPreviousForm(_ form: GLForm)
    func printForm(_ form: GLForm)
}



class GLForm: UITableView, UITableViewDelegate, UITableViewDataSource, GLFormCellDelegate, GLFormHeaderDelegate {
    
    weak var formDelegate: GLFormDelegate?
    var formRecord = FormRecord(id: GLDataManager.sharedInstance.getCurrentFormRecordId(), recordData: [])
    fileprivate let defaultLine: Int = 8
    /// The sum of the array is required to equal to 12
    fileprivate var columnRatio: [CGFloat]
    
    fileprivate lazy var formHeader: GLFormHeader = {
       let header = GLFormHeader(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: 44))
        header.delegate = self
        return header
    }()
    
    
    /// 初始化表格
    ///
    /// - Parameters:
    ///   - frame: frame
    ///   - columnRatio: 每一栏的比例
    init(frame: CGRect, columnRatio: [CGFloat]){
        self.columnRatio = columnRatio
        assert(columnRatio.reduce(0, {$0 + $1}) == 12, "The sum of the columnRatio is required to equal to 12")
        super.init(frame: frame, style: .plain)
//        layer.borderWidth = 2
//        layer.borderColor = UIColor.black.cgColor
        separatorStyle = .none
        bounces = false
        delegate = self
        dataSource = self
        tableHeaderView = formHeader
        register(GLFormCell.self, forCellReuseIdentifier: "FORMCELL")
        reloadData()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateRecord(_ formRecord: FormRecord) {
        self.formRecord = formRecord
        reloadData()
        formHeader.updateTotal(formRecord.recordData.total())
        if formRecord.recordData.count == 0 ,
           let cell = cellForRow(at: IndexPath(row: 0, section: 0)) as? GLFormCell {
            cell.turnToBeFirstResponder()
        }
    }
}
// MARK: - UITableViewDelegate
extension GLForm {
    internal func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60;
    }
    
    internal func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = GLFormCell(frame: CGRect(x: 0, y: 0, width: frame.width, height: 60 ))
        header.isHeader = true
        header.backgroundColor = UIColor.white
        header.loadContentView(with: columnRatio, customFrame: CGRect(x: 0, y: 0, width: frame.width, height: 60))
        let defaultTitles = ["Name", "Specification", "Amount", "Price"]
        header.setDefaultTitle(defaultTitles)
        return header
    }
    
    internal func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
}

// MARK: - UITalbleViewDataSurce
extension GLForm {
    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return formRecord.recordData.count > defaultLine ? formRecord.recordData.count + 1 : defaultLine
    }
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell  = tableView.dequeueReusableCell(withIdentifier: "FORMCELL", for: indexPath) as! GLFormCell
        if cell.hasLoaded == false {
            cell.loadContentView(with: columnRatio, keyboardType:[.default, .default, .decimalPad, .decimalPad])
        }
        if formRecord.recordData.count > indexPath.row {
            cell.loadRecord(formRecord.recordData[indexPath.row])
        } else {
            cell.loadRecord()
        }
        cell.delegate = self
        cell.indexPath = indexPath
        return cell
    }
}


// MARK: - UIScrollViewDelegate
extension GLForm {
    internal func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let firstResponder = UIApplication.shared.keyWindow?.perform(NSSelectorFromString("firstResponder")),
            let currentTf = firstResponder.takeRetainedValue() as? UITextField {
            currentTf.resignFirstResponder()
        }
    }
}

// MARK: - GLFormHeaderDelegate
extension GLForm {
    internal func previousButtonDidTapped(_ header: GLFormHeader) {
        if formDelegate != nil {
            formDelegate!.gotoPreviousForm(self)
        }
    }
    
    internal func nextButtonDidTapped(_ header: GLFormHeader) {
        if formDelegate != nil {
            formDelegate!.gotoNextForm(self)
        }
    }
    
    internal func printButtonDidTapped(_ header: GLFormHeader) {
        if formDelegate != nil {
            formDelegate!.printForm(self)
        }
    }
}


// MARK: - GLFormCellDelegate
extension GLForm {
    func recordDone(_ indexPath: IndexPath, _ goodsRecord: Goods) {
        if formRecord.recordData.contains(goodsRecord){
            formRecord.recordData.update(goodsRecord)
        } else {
            formRecord.recordData.append(goodsRecord)
        }
        formHeader.updateTotal(formRecord.recordData.total())
        reloadRows(at: [indexPath], with: .none)
        
        let nextCellIndexPath = IndexPath(row: indexPath.row + 1, section: indexPath.section)
        if let cell = cellForRow(at: nextCellIndexPath) as? GLFormCell {
            cell.turnToBeFirstResponder()
        }
    }
    
    func goodsNameStringDidChange(_ name: String) {
        
    }
}




