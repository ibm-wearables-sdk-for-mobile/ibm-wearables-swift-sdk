//
//  RegistrationViewController.swift
//  RecordApp
//
//  Created by Cirill Aizenberg on 1/24/16.
//  Copyright © 2016 IBM. All rights reserved.
//

import UIKit

class RegistrationViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var codeText: UITextField!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
        spinner.stopAnimating()
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    
    @IBAction func onContinueButtonClicked(sender: AnyObject) {
        spinner.startAnimating()
        continueButton.enabled = false
        validateCode();
    }
    
    //make code validation
    func validateCode(){
        if let code = codeText.text{
            RequestUtils.sendValidationRequest(code, onSuccess: onValidCode, onFailure: onInvalidCode)
        }
        
        else{
            Utils.showMsgDialog(self, withMessage: "Enter valid code!")
        }
    }
    
    //this function will be called in case the code is valid
    func onValidCode(){
        dispatch_async(dispatch_get_main_queue()) {
            self.spinner.stopAnimating()
            self.continueButton.enabled = true
            AppPreferences.setRegistrationCode(self.codeText.text!)
            self.performSegueWithIdentifier("moveToConnect", sender: self)
        }
    }
    
    //this function will be called in case the code is invalid
    func onInvalidCode(){
        dispatch_async(dispatch_get_main_queue()) {
            self.spinner.stopAnimating()
            self.continueButton.enabled = true
            Utils.showMsgDialog(self, withMessage:"Invalid registration code, please try again!")
        }
    }
}
