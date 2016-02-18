/*
*   © Copyright 2015 IBM Corp.
*
*   Licensed under the Mobile Edge iOS Framework License (the "License");
*   you may not use this file except in compliance with the License. You may find
*   a copy of the license in the license.txt file in this package.
*
*   Unless required by applicable law or agreed to in writing, software
*   distributed under the License is distributed on an "AS IS" BASIS,
*   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
*   See the License for the specific language governing permissions and
*   limitations under the License.
*/
import UIKit

class StartViewController: UIViewController, UITextFieldDelegate {
    
    @IBAction func onCancelClicked(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    @IBOutlet weak var startButton: UIButton!
    
    var timer:NSTimer!
    var counterValue = 3

    @IBOutlet weak var gestureNameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gestureNameTextField.delegate = self
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        dismissKeyboard()
        return false
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func onStartButtonClicked(sender: AnyObject) {
        
        if (isGestureNameEmpty()){
            Utils.showMsgDialog(self, withMessage:"Insert valid gesture name")
        }
        
        /*
        else if (isGestureNameContainsSpaces()){
            Utils.showMsgDialog("Gesture name cannot contain spaces")
        }
        */
        
        else if (isGestureExists()){
            Utils.showMsgDialog(self, withMessage: "Gesture with name '\(gestureNameTextField.text!)' already exists. choose diffrent name")
        }
        
        else {
            AppDelegate.trainingGestureName = gestureNameTextField.text
            self.performSegueWithIdentifier("moveToRecording", sender: self)
        }
    }
    
    func isGestureExists() -> Bool{
        return FileUtils.getJsFileNames().contains(gestureNameTextField.text!)
    }
    
    
    func isGestureNameEmpty() -> Bool{
        let characteres = gestureNameTextField.text?.characters
        return characteres?.count == 0
    }
    
    func isGestureNameContainsSpaces() -> Bool {
        return gestureNameTextField.text!.rangeOfString(" ") != nil
    }
}
