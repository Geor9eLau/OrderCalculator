//
//  GLTextField.swift
//  OrderCalculator
//
//  Created by George on 2017/7/19.
//  Copyright © 2017年 George. All rights reserved.
//

import UIKit

protocol GLTextFieldDelegate: class {
    func textFieldDidTapPreviousButton(_ textField: GLTextField)
    func textFieldDidTapNextButton(_ textField: GLTextField)
    func textFieldDidTapFinishButton(_ textField: GLTextField)
    func textFieldShouldTapReturn(_ textField: GLTextField) -> Bool
    func textFieldShouldStartEditing(_ textField: GLTextField) -> Bool
}

class GLTextField: UITextField, UITextFieldDelegate {
    
    weak var gl_delegate: GLTextFieldDelegate?
    override init(frame: CGRect) {
        super.init(frame: frame)
        autocorrectionType = .no
        autocapitalizationType = .none
        addTool()
        delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addTool() {
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: frame.width, height: 35))
        toolBar.tintColor = UIColor.black
        toolBar.backgroundColor = UIColor.gray
        let previousBtn = UIBarButtonItem(title: "上一步", style: .plain, target: self, action: #selector(previousBtnDidClicked))
        previousBtn.setTitleTextAttributes([NSFontAttributeName: UIFont.systemFont(ofSize: 15)], for: .normal)
        previousBtn.setTitlePositionAdjustment(UIOffset(horizontal: 0, vertical: 5) , for: .default)
        
        
        let nextBtn = UIBarButtonItem(title: "下一步", style: .plain, target: self, action: #selector(nextBtnDidClicked))
        nextBtn.setTitleTextAttributes([NSFontAttributeName: UIFont.systemFont(ofSize: 15)], for: .normal)
        nextBtn.setTitlePositionAdjustment(UIOffset(horizontal: 0, vertical: 2.5) , for: .default)

        
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace , target: nil, action: nil)

        let finishBtn = UIBarButtonItem(title: "完成", style: .plain, target: self, action: #selector(finishBtnDidClicked))
        finishBtn.setTitleTextAttributes([NSFontAttributeName: UIFont.systemFont(ofSize: 15)], for: .normal)
        finishBtn.setTitlePositionAdjustment(UIOffset(horizontal: 0, vertical: -2.5) , for: .default)
        
        toolBar.items = [space, previousBtn, space, nextBtn, space, space, space, space, space, space, finishBtn]
        inputAccessoryView = toolBar
    }
    
    
    @objc private func previousBtnDidClicked() {
        if gl_delegate != nil {
            return gl_delegate!.textFieldDidTapPreviousButton(self)
        }
    }
    
    @objc private func nextBtnDidClicked() {
        if gl_delegate != nil {
            return gl_delegate!.textFieldDidTapNextButton(self)
        }
    }
    
    @objc private func finishBtnDidClicked() {
        if gl_delegate != nil {
            return gl_delegate!.textFieldDidTapFinishButton(self)
        }
    }
    
}

extension GLTextField {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if gl_delegate != nil {
           return gl_delegate!.textFieldShouldTapReturn(self)
        }
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if gl_delegate != nil {
            return gl_delegate!.textFieldShouldStartEditing(self)
        }
        return true
    }
}


