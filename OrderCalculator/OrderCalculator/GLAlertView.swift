//
//  GLAlertView.swift
//  OrderCalculator
//
//  Created by George on 2017/7/20.
//  Copyright © 2017年 George. All rights reserved.
//

import UIKit

struct GLAlertViewUX{
    static let originalFrame = CGRect(x: 0, y: 0, width: Global.screenWidth, height: 64.0)
//    static let destinationFrame = CGRect(x: 0, y: 0, width: Global.screenWidth, height: 64.0)
}

class GLAlertView: UILabel {
    
    static func show(_ title: String) {
        let view = GLAlertView(frame: GLAlertViewUX.originalFrame)
        view.text = title
        view.alpha = 0
        UIApplication.shared.keyWindow?.addSubview(view)
        UIView.animate(withDuration: 0.5, animations: {
            view.alpha = 1
        }) { (finished) in
            if finished {
                UIView.animate(withDuration: 0.5, delay: 1, options:[]  ,animations: {
                    view.alpha = 0
                }, completion: { (finished) in
                    if finished {
                        view.removeFromSuperview()
                    }
                })
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.red
        textColor = UIColor.white
        font = UIFont.systemFont(ofSize: 16)
        textAlignment = .center
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
