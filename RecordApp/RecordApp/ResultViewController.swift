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

class ResultViewController: UIViewController, UITextFieldDelegate {
    
    var uuid:String!
    var url:String!
    var sensitivity:Double!
    
    @IBOutlet weak var urlText: UITextField!
    @IBOutlet weak var idText: UITextField!
    
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var resultView: UIView!
    @IBOutlet weak var downloadView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Record completed"
        
        
        urlText.delegate = self
        idText.delegate = self
        
        
        idText.text = uuid
        urlText.text = url.substringFromIndex(url.startIndex.advancedBy(8))
        
        
        dispatch_async(dispatch_get_main_queue()) {
            
            SensitivityUtils.set(AppDelegate.trainingGestureName, sensitivity: self.sensitivity)
            Utils.downloadFile(self.url, toPath: FileUtils.getFilePath(AppDelegate.trainingGestureName))
            
            
            self.downloadView.hidden = true
            self.resultView.hidden = false
        }
    }
    
    @IBAction func onDoneButtonClicked(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func onTapDetected(sender: AnyObject) {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        dismissKeyboard()
        return false
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}
