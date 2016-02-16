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

import Foundation
import IBMMobileEdge


class Utils {
    
    static func showMsgDialog(vc:UIViewController, withMessage message:String){
        
        let alert = UIAlertController(title: "Record Application", message: message, preferredStyle: .Alert)
        let continueAction = UIAlertAction(title: "Continue", style: .Default, handler: nil)
        alert.addAction(continueAction)
        vc.presentViewController(alert, animated: true, completion: nil)
        
        /*
        let alert:UIAlertView = UIAlertView()
        alert.title = "Record Application"
        alert.message = message
        alert.addButtonWithTitle("Continue")
        alert.show()
        */
    }
    
    static func downloadFile(url:String, toPath path:String){
        if let jsFileUrl = NSURL(string: url) {
            if NSFileManager().fileExistsAtPath(path) {
                print("The file already exists at path")
            } else {
                
                if let jsFileData = NSData(contentsOfURL: jsFileUrl){
                    //save to file
                    jsFileData.writeToFile(path, atomically: true)
                }
            }
        }
    }
    
    /*
    static func updateSensitivityInJS(){
        
        var payload = Dictionary<String,AnyObject>()
        
        //before using the function, common needs to be loaded
        JSEngine.instance.loadJS("commonClassifier")
        
        for name in FileUtils.getJsFileNames(){
            payload[name] = SensitivityUtils.get(name)
        }
        
        if payload.count > 0{
            print("set sensitivity payload = \(payload)")
            JSEngine.instance.executeMethod("setGesturesSensitivity", payload: payload)
        }
    }
    */
}