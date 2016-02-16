//
//  TestingViewController.swift
//  RecordApp
//
//  Created by Cirill Aizenberg on 1/4/16.
//  Copyright © 2016 IBM. All rights reserved.
//

import UIKit

class SensingViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
