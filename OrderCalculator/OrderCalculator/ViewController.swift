//
//  ViewController.swift
//  OrderCalculator
//
//  Created by George on 2017/7/18.
//  Copyright © 2017年 George. All rights reserved.
//

import UIKit

class ViewController: UIViewController, GLFormDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        let form = GLForm(frame: UIScreen.main.bounds, columnRatio: [3, 3, 3, 3])
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
        
    }
    
    func gotoNextForm(_ form: GLForm) {
        
    }
    
    func print(_ form: GLForm) {
        
    }
}

