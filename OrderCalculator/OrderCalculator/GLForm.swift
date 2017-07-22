//
//  GLForm.swift
//  OrderCalculator
//
//  Created by George on 2017/7/18.
//  Copyright © 2017年 George. All rights reserved.
//

import UIKit

struct GLFormUX {
    static let rowHeight: CGFloat = 40
    static let sectionHeaderFunctionViewHeight: CGFloat = 44
    static let sectionHeaderViewHeight: CGFloat = GLFormUX.rowHeight + GLFormUX.sectionHeaderFunctionViewHeight
    static let fontSize: CGFloat = 15
    static let recordIDLabelWidth: CGFloat = 50
    static let searchViewWidth = Global.screenWidth * (2 / 3.0)
    static let searchViewHeight: CGFloat = 150
    static let searchTableViewRowHeight: CGFloat = 30
}


protocol GLFormCellDelegate: class {
    func cell(_ cell:GLFormCell, didFinishRecord goodsRecord: Goods)
    func cell(_ cell: GLFormCell, goodsNameStringDidChange name: String)
    func cell(_ cell: GLFormCell, goodsNameDidFinishEditing name: String)
    func goodsNameBeginEditing(_ cell: GLFormCell)
    func shouldNotBeEditing(_ cell: GLFormCell)
}

class GLFormCell: UITableViewCell, GLTextFieldDelegate {
    let columnTextFiledOriginTag = 8888
    fileprivate var columnRatio: [CGFloat] = []
    var hasLoaded: Bool = false
    var isReadyToEdit: Bool = false
    weak var delegate: GLFormCellDelegate?
    var indexPath: IndexPath!
    var isHeader: Bool = false
    fileprivate var goodsRecord = Goods.default
    fileprivate var goodsRecordId: String {
        return "\(indexPath.row)"
    }
    
    var recordIDLabel: UILabel = {
        let recordIDLabel = UILabel()
        recordIDLabel.font = UIFont.systemFont(ofSize: GLFormUX.fontSize)
        recordIDLabel.textAlignment = .center
        return recordIDLabel
    }()

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
        
        recordIDLabel.frame = CGRect(x: 0, y: 0, width: GLFormUX.recordIDLabelWidth, height: height)
        addSubview(recordIDLabel)
        
        var tmpTfOriginX:CGFloat = GLFormUX.recordIDLabelWidth
        let contentWidth = width - GLFormUX.recordIDLabelWidth
        for (index, ratio) in columnRatio.enumerated() {
            let tmpTf = GLTextField(frame: CGRect(x: tmpTfOriginX, y: 0, width: contentWidth * (ratio / 12.0), height: height))
            tmpTf.gl_delegate = self
            tmpTf.borderStyle = .none
            tmpTf.textAlignment = .center
            tmpTf.font = UIFont.systemFont(ofSize: GLFormUX.fontSize)
            tmpTf.tag = columnTextFiledOriginTag + index
            tmpTf.isUserInteractionEnabled = !isHeader
            tmpTf.keyboardType = keyboardType == nil ? .default : keyboardType![index]
            #if true
                if index == 0 {
                    tmpTf.addTarget(self, action: #selector(textFiledValueChange(_:)), for: .editingChanged)
                }
            #endif
            
            addSubview(tmpTf)
            if index < columnRatio.count {
                let dividedLine = UIView(frame: CGRect(x: tmpTfOriginX, y: 0, width: 1, height: height))
                dividedLine.backgroundColor = UIColor.black
                addSubview(dividedLine)
            }
            tmpTfOriginX += contentWidth * (ratio / 12.0)
            
        }
        hasLoaded = true
    }
    
    
    /// 加载商品数据
    ///
    /// - Parameter goodsRecord: 商品数据
    func loadRecord(_ goodsRecord: Goods = Goods.default) {
        recordIDLabel.text = "\(indexPath.row + 1)"
        self.goodsRecord = goodsRecord
        for index in 0...2 {
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
    
    func updateGoodsName(_ name: String) {
        if let tf = viewWithTag(columnTextFiledOriginTag) as? UITextField{
            tf.text = name
        }
    }
    
    @objc private func textFiledValueChange(_ textField: UITextField){
        if let validDelegate = delegate {
            validDelegate.cell(self, goodsNameStringDidChange: textField.text!)
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
        
        if (textField.text?.characters.count)! > 0 {
            goodsRecord.id = goodsRecordId
            goodsRecord.update(type: textField.tag - columnTextFiledOriginTag, content: textField.text!)
            if textField.tag + 1 - columnTextFiledOriginTag < columnRatio.count,
            let tf = viewWithTag(textField.tag + 1) as? GLTextField{
                tf.becomeFirstResponder()
            } else {
                delegate?.cell(self, didFinishRecord: goodsRecord)
            }
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
            if textField.tag + 1 - columnTextFiledOriginTag < columnRatio.count{
                textField.resignFirstResponder()
            }else {
                if let validDelegate = delegate {
                    validDelegate.cell(self, didFinishRecord: goodsRecord)
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
//            if isReadyToEdit {
                delegate?.goodsNameBeginEditing(self)
                return true
//            } else {
//                delegate?.shouldNotBeEditing(self)
//                return false
//            }
            
        } else {
            if goodsRecord.name.characters.count > 0 {
                return true
            } else {
                GLAlertView.show("请先输入商品名称!")
                return false
            }
        }
    }
    
    internal func textFieldDidFinishEnditing(_ textField: GLTextField) {
        if textField.tag - columnTextFiledOriginTag == 0 && (textField.text?.characters.count)! > 0 {
            goodsRecord.name = textField.text!
            if delegate != nil {
                delegate!.cell(self, goodsNameDidFinishEditing: textField.text!)
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
        let totalLabel = UILabel(frame: CGRect(x: self.frame.width / 2 + self.frame.width / 4 - 20, y: 0, width: (self.frame.width / 4), height: GLFormUX.sectionHeaderFunctionViewHeight))
        totalLabel.text = "金额:"
        totalLabel.adjustsFontSizeToFitWidth = true
        totalLabel.textColor = UIColor.black
        totalLabel.textAlignment = .left
        return totalLabel
    }()
    
    
    override func draw(_ rect: CGRect) {
        let topLine = UIBezierPath()
        topLine.move(to: CGPoint(x: 0, y: 0))
        topLine.addLine(to: CGPoint(x: rect.width, y: 0))
        topLine.lineWidth = 1
        topLine.stroke()
        
        let bottomLine = UIBezierPath()
        bottomLine.move(to: CGPoint(x: 0, y: GLFormUX.sectionHeaderFunctionViewHeight))
        bottomLine.addLine(to: CGPoint(x: rect.width, y: GLFormUX.sectionHeaderFunctionViewHeight))
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
    
    init(frame: CGRect, columnRatio: [CGFloat] = [3, 3, 3, 3], defaultTitles:[String] = ["None", "None", "None", "None"]) {
        super.init(frame: frame)
        backgroundColor = UIColor.white
        
        let previousBtn = UIButton(frame: CGRect(x: 20, y: 0, width: (frame.width / 4 - 30), height: GLFormUX.sectionHeaderFunctionViewHeight))
        previousBtn.setTitle("<", for: .normal)
        previousBtn.setTitleColor(UIColor.black, for: .normal)
        previousBtn.addTarget(self, action: #selector(previousBtnDidClicked), for: .touchUpInside)
        
        let nextBtn = UIButton(frame: CGRect(x: 20 + (frame.width / 4 - 30) + 20, y: 0, width: (frame.width / 4 - 20), height: GLFormUX.sectionHeaderFunctionViewHeight))
        nextBtn.setTitle(">", for: .normal)
        nextBtn.setTitleColor(UIColor.black, for: .normal)
        nextBtn.addTarget(self, action: #selector(nextBtnDidClicked), for: .touchUpInside)
        
        let printBtn = UIButton(frame: CGRect(x: frame.width / 2, y: 0, width: (frame.width / 4 - 30), height: GLFormUX.sectionHeaderFunctionViewHeight))
        printBtn.setTitle("打印", for: .normal)
        printBtn.setTitleColor(UIColor.black, for: .normal)
        printBtn.addTarget(self, action: #selector(printBtnDidClicked), for: .touchUpInside)
    
        let defaultTitleView = GLFormCell(frame: CGRect(x: 0, y: GLFormUX.sectionHeaderFunctionViewHeight, width: frame.width, height: GLFormUX.rowHeight ))
        defaultTitleView.isHeader = true
        defaultTitleView.backgroundColor = UIColor.white
        defaultTitleView.loadContentView(with: columnRatio, customFrame: CGRect(x: 0, y: 0, width: frame.width, height: GLFormUX.rowHeight))
        defaultTitleView.setDefaultTitle(defaultTitles)
        defaultTitleView.frame = CGRect(x: 0, y: GLFormUX.sectionHeaderFunctionViewHeight, width: frame.width, height: GLFormUX.rowHeight )
        defaultTitleView.recordIDLabel.text = "序号"
        addSubview(previousBtn)
        addSubview(nextBtn)
        addSubview(printBtn)
        addSubview(totalLabel)
        addSubview(defaultTitleView)
    }
    
    func updateTotal(_ total: Float){
        totalLabel.text = "金额: \(total)"
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

protocol GLFormSearchViewDelegate: class {
    func tableView(_ tableView: GLFormSearchView, didSelectGoodsRecord record: GoodsNameRecord, at indexPath: IndexPath)
}

class GLFormSearchView: UITableView, UITableViewDelegate, UITableViewDataSource {
    weak var gl_delegate: GLFormSearchViewDelegate?
    var currentIndexPath: IndexPath?
    
    fileprivate var searchRearchResult: [GoodsNameRecord] = []
    
    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        layer.borderColor = UIColor.black.cgColor
        layer.borderWidth = 1
        delegate = self
        dataSource = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateResult(_ result: [GoodsNameRecord]) {
        searchRearchResult = result
        reloadData()
    }
    
    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchRearchResult.count
    }
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "SearchCell")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "SearchCell")
        }
        cell!.textLabel?.text = searchRearchResult[indexPath.row].name
        return cell!
    }
    
    internal func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return GLFormUX.searchTableViewRowHeight
    }
    
    internal func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if gl_delegate != nil {
            gl_delegate!.tableView(self, didSelectGoodsRecord: searchRearchResult[indexPath.row], at: indexPath)
        }
    }
}





// MARK: -
protocol GLFormDelegate: class {
    func gotoNextForm(_ form: GLForm)
    func gotoPreviousForm(_ form: GLForm)
    func printForm(_ form: GLForm)
    func formDidScroll(_ form: GLForm)
    func form(_ form: GLForm, goodsNameDidChange name: String)
    func form(_ form: GLForm, didFinishGoodsNameEditing name: String)
}



class GLForm: UITableView, UITableViewDelegate, UITableViewDataSource, GLFormCellDelegate, GLFormHeaderDelegate {
    
    weak var formDelegate: GLFormDelegate?
    var formRecord = FormRecord(id: GLDataManager.sharedInstance.getCurrentFormRecordId(), recordData: [])
    fileprivate let defaultLine: Int = (Int(Global.screenHeight / GLFormUX.rowHeight))
    /// The sum of the array is required to equal to 12
    fileprivate var columnRatio: [CGFloat]
    fileprivate var defaultTitles: [String]
    fileprivate var keyboardType: [UIKeyboardType]
    fileprivate lazy var formHeader: GLFormHeader = {
        let header = GLFormHeader(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: GLFormUX.sectionHeaderViewHeight), columnRatio: self.columnRatio, defaultTitles: self.defaultTitles)
        header.delegate = self
        return header
    }()
    
    
    /// 初始化表格
    ///
    /// - Parameters:
    ///   - frame: frame
    ///   - columnRatio: 每一栏的比例
    init(frame: CGRect, columnRatio: [CGFloat], defaultTitles:[String], keyboardType: [UIKeyboardType]){
        self.columnRatio = columnRatio
        self.defaultTitles = defaultTitles
        self.keyboardType = keyboardType
        assert(columnRatio.reduce(0, {$0 + $1}) == 12, "The sum of the columnRatio is required to equal to 12")
        super.init(frame: frame, style: .plain)
        separatorStyle = .none
        bounces = false
        delegate = self
        dataSource = self
        register(GLFormCell.self, forCellReuseIdentifier: "FORMCELL")
        reloadData()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateGoodsName(_ name: String,at IndexPath: IndexPath) {
        if let cell = cellForRow(at: IndexPath) as? GLFormCell {
            cell.updateGoodsName(name)
        }
    }
    
    func updateFormRecord(_ formRecord: FormRecord) {
        self.formRecord = formRecord
        reloadData()
        formHeader.updateTotal(formRecord.recordData.total())
        if formRecord.recordData.count == 0 ,
           let cell = cellForRow(at: IndexPath(row: 0, section: 0)) as? GLFormCell {
            cell.turnToBeFirstResponder()
        }
    }
    
    func updateGoodsRecord(_ goodsRecord: Goods) {
        if formRecord.recordData.contains(goodsRecord){
            formRecord.recordData.update(goodsRecord)
        } else {
            formRecord.recordData.append(goodsRecord)
        }
    }
    
}
// MARK: - UITableViewDelegate
extension GLForm {
    internal func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return GLFormUX.rowHeight;
    }
    
    internal func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return formHeader
    }
    
    internal func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return formHeader.frame.size.height
    }
}

// MARK: - UITalbleViewDataSurce
extension GLForm {
    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return formRecord.recordData.count + defaultLine
    }
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell  = tableView.dequeueReusableCell(withIdentifier: "FORMCELL", for: indexPath) as! GLFormCell
        cell.delegate = self
        cell.indexPath = indexPath
        if cell.hasLoaded == false {
            cell.loadContentView(with: columnRatio, keyboardType:keyboardType)
        }
        if formRecord.recordData.count > indexPath.row{
            cell.loadRecord(formRecord.recordData[indexPath.row])
//            cell.isReadyToEdit = true
        } else {
            cell.loadRecord()
//            if formRecord.recordData.count == indexPath.row {
//                cell.isReadyToEdit = true
//            }else{
//              cell.isReadyToEdit = false
//            }
        }
        
        return cell
    }
}


// MARK: - UIScrollViewDelegate
extension GLForm {
    internal func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        UIApplication.shared.keyWindow?.endEditing(false)
        if formDelegate != nil {
            formDelegate?.formDidScroll(self)
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
    
    internal func cell(_ cell: GLFormCell, didFinishRecord goodsRecord: Goods) {
        updateGoodsRecord(goodsRecord)
//        reloadRows(at: [cell.indexPath], with: .none)
        formHeader.updateTotal(formRecord.recordData.total())
        reloadData()
        
        let nextCellIndexPath = IndexPath(row: cell.indexPath.row + 1, section: cell.indexPath.section)
        if let cell = cellForRow(at: nextCellIndexPath) as? GLFormCell {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                cell.turnToBeFirstResponder()
            })
        }
    }
    
    internal func cell(_ cell: GLFormCell, goodsNameStringDidChange name: String) {
        if formDelegate != nil {
            formDelegate!.form(self, goodsNameDidChange: name)
        }
    }
    
    internal func goodsNameBeginEditing(_ cell: GLFormCell) {
        scrollToRow(at: cell.indexPath, at: .top, animated: true)
    }
    
    internal func cell(_ cell: GLFormCell, goodsNameDidFinishEditing name: String) {
        updateGoodsRecord(cell.goodsRecord)
//        self.reloadData()
        if formDelegate != nil {
            formDelegate?.form(self, didFinishGoodsNameEditing: name)
        }
    }
    
    internal func shouldNotBeEditing(_ cell: GLFormCell) {
//        let validRow = formRecord.recordData.count
//        let indexPath = IndexPath(row: validRow, section: cell.indexPath.section)
//        if let cell = cellForRow(at: indexPath) as? GLFormCell{
//            cell.turnToBeFirstResponder()
//            scrollToRow(at: indexPath, at: .top, animated: true)
//        }
    }
}



